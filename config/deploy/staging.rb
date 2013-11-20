set :stage, :staging

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# role :app, %w{deploy@example.com}
# role :web, %w{deploy@example.com}
# role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.

set :node, {
  :db => {
    :mysql => {
      :server_root_password => 'change_me',
      :server_debian_password => 'change_me',
      :server_repl_password => 'change_me',
      :bind_address => '127.0.0.1'
    },
    :rails => {
      :user => 'deploy',
      :group => 'deploy',
      :mysql => {
        :user => 'my_project',
        :password => 'change_me',
        :db_prefix => 'my_project'
      }
    },
    :run_list => [ "recipe[rails::database]" ]
  },
  :web => {
    :run_list => [ "recipe[rails::webserver]" ]
  }
}

set :web_ip, 'example.com'
set :db_ip, '127.0.0.1'
set :db_username, 'my_project'
set :db_password, 'change_me'
set :nginx_host_name, 'my_project.example.com'

server (fetch :web_ip), user: 'deploy', roles: %w{web db}, node: node

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options

# fetch(:default_env).merge!(rails_env: :staging)
