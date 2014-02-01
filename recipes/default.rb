#
# Cookbook Name:: rails
# Recipe:: default
#
# Copyright (C) 2013 Dane Lipscombe
# 
# All rights reserved - Do Not Redistribute
#

include_recipe "rails::rails"
include_recipe "rails::webserver"
include_recipe "rails::mysql"
include_recipe "rails::phpmyadmin"
