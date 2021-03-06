set :application, 'my_project'

set :repo_url, 'git@example.com:me/my_repo.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/home/deploy/#{fetch :application}"
set :scm, :git
set :rbenv_type, :system
set :rbenv_ruby, '2.0.0-p247'
set :rbenv_custom_path, '/opt/rbenv'

set :migration_role, 'web'

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  def template(from, to)
    erb = File.read(File.expand_path("../deploy/templates/#{from}", __FILE__))
    text = ERB.new(erb).result(binding)
    File.open("/tmp/#{from}", 'w') {|f| f.write(text) }
    upload!("/tmp/#{from}", "/tmp/#{from}")
    sudo "mv /tmp/#{from} #{to}"
  end

  desc 'Stop Unicorn'
  after :updated, :stop_unicorn do
    on roles(:web) do
      execute "/etc/init.d/unicorn_#{fetch :application} stop"
    end
  end
  
  desc 'Start Unicorn'
  after :published, :start_unicorn do
    on roles(:web) do
      execute "mkdir -p #{current_path}/tmp/pids"
      execute "/etc/init.d/unicorn_#{fetch :application} start"
    end
  end

  before :updated, :setup_rails_config do
    on roles(:web) do
      template("nginx.conf.erb", "/etc/nginx/sites-enabled/#{fetch :application}")
      template("unicorn_init.sh.erb", "/etc/init.d/unicorn_#{fetch :application}")
      sudo ("chmod u+x /etc/init.d/unicorn_#{fetch :application}")

      template("database.yml.erb", "#{release_path}/config/database.yml")
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Setup DB'
  task :dbsetup do
    on roles(:web) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch :stage} bundle exec rake db:setup"
    end
  end

  after :updated, "deploy:compile_assets"
  after :updated, "deploy:migrate"
  after :finishing, 'deploy:cleanup'

end

namespace :chef do
  task :bootstrap do
    on roles(:all) do
      execute "curl -L https://www.opscode.com/chef/install.sh | sudo bash"
    end
  end

  task :provision do
    require "json"

    # Generate node.json
    on roles(:all) do |role|
      node = fetch :node
      role.roles.each do |role_name|
        data = node[role_name].to_json
        filename = "node_#{fetch :stage}_#{role_name.to_s()}.json"
        File.open("chef/#{filename}", 'w') {|f| f.write(data) }
      end

    end

    # Update cookbooks
    run_locally do
      execute("rm -rf chef/cookbooks")
      execute("berks install --path chef/cookbooks")
    end

    on roles(:all) do |role|
      # Rsync cookbooks to each server
      run_locally do
        rsync = "rsync -avz --delete-after --exclude .git* chef #{role.user}@#{role.hostname}:"
        execute(rsync)
      end

      # Run chef for each role on each server
      role.roles.each do |role_name|
        execute("sudo bash -c 'cd chef && chef-solo -c solo.rb -j node_#{fetch :stage}_#{role_name.to_s()}.json'")
      end
      
    end

  end
end

