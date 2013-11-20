# rails-cookbook

Cookbook created with Berkshelf for a complete Rails 4 environment including:
* Vagrant 2 virtual machine configuration
* Capistrano deploy to server on unicorn with nginx
* Capistrano rsync cookbooks and run chef-solo remotely
* Recipes for rbenv using ruby 2.0, mysql, nginx and phpmyadmin

# Setup
`bundle install`  
`vagrant plugin install vagrant-berkshelf`

# Vagrant config

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

### Basic deploy user setup for CentOS

`useradd -m -s /bin/bash deploy`

`visudo`  
add line  
`deploy  ALL=(ALL)       NOPASSWD: ALL`  
comment out  
`# Defaults    requiretty`  

`su - deploy`  
`ssh-keygen -t rsa`  
`cat .ssh/id_rsa.pub`  
give key deploy access to your git repository  

`vi .ssh/authorized_keys`  
paste public key from deploy location  
`chmod 600 -R .ssh/authorized_keys`
