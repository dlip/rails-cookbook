include_recipe "mysql::server"
include_recipe "database::mysql"

%w[production staging development test].each do | env_name |
  db_name = "#{node[:rails][:mysql][:db_prefix]}_#{env_name}"

  mysql_connection_info = {
    :host     => 'localhost',
    :username => 'root',
    :password => node['mysql']['server_root_password']
  }
  
  mysql_database db_name do
    connection mysql_connection_info 
    action :create
  end

  mysql_database_user node[:rails][:mysql][:user] do
    connection    mysql_connection_info
    password      node[:rails][:mysql][:password]
    database_name db_name
    host          '%'
    privileges    [:all]
    action        :grant
  end

  mysql_database_user node[:rails][:mysql][:user] do
    connection    mysql_connection_info
    password      node[:rails][:mysql][:password]
    database_name db_name
    host          'localhost'
    privileges    [:all]
    action        :grant
  end
end
