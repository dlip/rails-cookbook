# rails-cookbook

Cookbook created with Berkshelf for a complete Rails 4 environment including:
* Vagrant v1.3.5 (config version 2) virtual machine
* Capistrano 3 deploy to server on unicorn with nginx
* Chef-solo provision (rsync cookbooks and run with capistrano)
* Recipes for rbenv using ruby 2.0, mysql, nginx and phpmyadmin

# Setup
`bundle install`  
`vagrant plugin install vagrant-berkshelf`  
`vagrant up`

# Vagrant config

## PhpMyAdmin
http://localhost:8888/  
username: root  
password: rootpass  

## Chef Solo
### Config
Requires auto sudo access on deploy user. This assumes you have a rails config for staging, you can rename to production etc. as you like.  
* Config in `config/deploy/staging.rb`  
    * The chef config is created from the `:node` array. `:db` and `:web` is the config for each role. 
* Templates database.yml etc. in `config/deploy/templates`

### Commands
Install chef-solo  
`bundle exec cap staging chef:bootstrap`

Rsync cookbooks to remote and run  
`bundle exec cap staging chef:provision`

### Deploy user setup for CentOS
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
