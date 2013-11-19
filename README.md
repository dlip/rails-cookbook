# rails-berkshelf

Rails 4 dev environment setup with rbenv using ruby 2.0, mysql, nginx and phpmyadmin.

Also contains capistrano tasks to run chef-solo on remote.

# Requirements
`bundle install`  
`vagrant plugin install vagrant-berkshelf`

# Usage

## PhpMyAdmin
http://localhost:8888/  
username: root  
password: rootpass  

## Chef Solo
Requires auto sudo acces on deploy user. You should edit the node options in chef/node_staging.json, and create other environments as needed.

Install chef-solo
`bundle exec cap staging chef:bootstrap`

Rsync cookbooks to remote and run
`bundle exec cap staging chef:provision`
