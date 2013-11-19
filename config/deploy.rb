set :application, 'my_project'

# set :repo_url, 'git@example.com:me/my_repo.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/home/deploy/#{fetch :application}"
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end

namespace :chef do
  task :bootstrap do
    on roles(:all) do
      execute "curl -L https://www.opscode.com/chef/install.sh | sudo bash"
    end
  end

  task :provision do
    on roles(:all) do |role|
      run_locally do
        execute("rm -rf chef/cookbooks")
        execute("berks install --path chef/cookbooks")
        rsync = "rsync -avz --delete-after --exclude .git* chef #{role.user}@#{role.hostname}:"
        execute(rsync)
      end
      
      execute("sudo bash -c 'cd chef && chef-solo -c solo.rb -j node_#{fetch :stage}.json'")
    end
  end
end

