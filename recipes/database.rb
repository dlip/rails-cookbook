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
end


include_recipe "nginx"
include_recipe "php::fpm"
include_recipe "phpmyadmin"

packages = %w[php-mbstring php-mcrypt php-gd php-mysql]
packages.each do |name|
    package name
end

directory "/var/lib/php/session" do
  owner "root"
  group "root"
  mode 00777
  action :create
end

template "#{node['nginx']['dir']}/sites-enabled/phpmyadmin" do
  source 'phpmyadmin.conf.erb'
  owner 'root'
  group 'root'
  notifies :restart, "service[nginx]"
  mode 00644
end
