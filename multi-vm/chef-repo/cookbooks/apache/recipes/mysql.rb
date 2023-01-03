file '/var/lib/mysql/my.cnf' do
  owner 'mysql'
  group 'mysql'
  action :create_if_missing
end

file '/etc/my.cnf' do
  owner 'mysql'
  group 'mysql'
  action :create_if_missing
end

execute 'set-mysql-password' do
  command 'sudo mysqladmin -uroot password mysqlpsw'
  action :run
end

execute 'create-user' do
  command 'sudo mysql -u root -password=mysqlpsw -e "CREATE USER IF NOT EXISTS \'wpuser\'@\'localhost\' IDENTIFIED BY \'wppsw\';"'
  action :run
end

execute 'create-wp-db' do
  command 'sudo mysql -u root -password=mysqlpsw -e "CREATE DATABASE IF NOT EXISTS wordpressdb;"'
  action :run
end

execute 'grant-privileges' do
  command 'sudo mysql -u root -password=mysqlpsw -e "GRANT ALL PRIVILEGES ON *.* TO \'wpuser\'@\'localhost\'; FLUSH PRIVILEGES;"'
  action :run
end

