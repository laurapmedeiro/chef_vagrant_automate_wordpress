#
# Cookbook:: apache
# Recipe:: default
#
# Copyright:: 2023, The Authors, All Rights Reserved.

if platform?('ubuntu')
  apt_update 'Update the apt cache daily' do
    frequency 86400
    action :periodic
  end
  
  # Install needed package
  package 'apache2'
  package 'mysql-server'

  #Launch Apache Server
  service 'apache2' do
    supports :status => true
    action :nothing
  end

  #Launch mySql
  service 'mysql' do
    supports :status => true
    action :start
  end
    
  # Apache configuration
  file '/etc/apache2/sites-enabled/000-default.conf' do
    action :delete
  end
    
  template '/etc/apache2/sites-available/vagrant.conf' do
    source 'wordpress.conf.erb'
    notifies :restart, resources(:service => "apache2")
  end
    
  link '/etc/apache2/sites-enabled/vagrant.conf' do
    to '/etc/apache2/sites-available/vagrant.conf'
    notifies :restart, resources(:service => "apache2")
  end
    
  execute 'configure-apache-wordpress' do
    command 'sudo a2ensite vagrant; 
						 sudo a2enmod rewrite;
             sudo a2dissite 000-default; 
						 sudo service apache2 reload'
    action :run
  end
    
  # cooobook_file => transfer files. 
  # "#{node['apache']['document_root']}/index.html"  is path to the file to be created
  # source 'index.html' significa que dentro de la carpeta "files" busque "index.html"
  cookbook_file "#{node['apache']['document_root']}/index.html" do
    source 'index.html'
    only_if do
      File.exist?('/etc/apache2/sites-enabled/vagrant.conf')
    end
  end

  include_recipe '::mysql'
  include_recipe '::wordpress'
    
elsif platform?('centos')

  # Install and configure Apache
  package 'httpd'

	service 'httpd' do
		supports :status => true
		action :nothing
	end

  template '/etc/httpd/conf/vagrant.conf' do
    source 'wordpress.conf.erb'
    notifies :restart, resources(:service => "httpd")
  end
	
  link '/etc/httpd/conf.d/vagrant.conf' do
    to '/etc/httpd/conf/vagrant.conf'
    notifies :restart, resources(:service => "httpd")
  end

  # cooobook_file => transfer files. 
  # "#{node['apache']['document_root']}/index.html"  is path to the file to be created
  # source 'index.html' significa que dentro de la carpeta "files" busque "index.html"
  cookbook_file "#{node['apache']['document_root']}/index.html" do
    source 'index.html'
    only_if do
      File.exist?('/etc/httpd/conf.d/vagrant.conf')
    end
  end

  # mysql80-community-release-el7-7.noarch.rpm
  execute 'install-mysql-package' do
    command 'curl -sSLO https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm;
             md5sum mysql80-community-release-el7-7.noarch.rpm;
             sudo rpm -ivh mysql80-community-release-el7-7.noarch.rpm;
             sudo yum install mysql-server -y'
    ignore_failure true
  end

  service 'mysqld' do
    supports :status => true
    action :start
  end


  #include_recipe '::mysql'

else 
    log 'invalid-platform' do
        message 'The platform introduce is not configure'
        level :info
    end
end