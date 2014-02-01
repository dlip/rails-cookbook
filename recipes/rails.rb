group node[:rails][:group]

user node[:rails][:user] do
  group node[:rails][:group]
  system true
  shell "/bin/bash"
end

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

# Ruby
rbenv_ruby "#{node[:rails][:ruby][:version]}" do
  ruby_version node[:rails][:ruby][:version]
  global true
end

# Gems
rbenv_gem "bundler" do
  ruby_version node[:rails][:ruby][:version]
end

rbenv_gem "rails" do
  ruby_version node[:rails][:ruby][:version]
end

bash "Fix rbenv path permissions for our user" do
  user "root"
  cwd "/opt"
  code <<-EOH
    chgrp -R rbenv rbenv
    chmod -R g+rwxX rbenv
  EOH
end

package "mysql-devel"
package "sqlite-devel"
include_recipe "nodejs"
