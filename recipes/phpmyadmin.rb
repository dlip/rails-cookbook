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
