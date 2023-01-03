package 'wget'
package 'php'
package 'php-mysql'

remote_file '/usr/local/bin/wp' do
    source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
    mode '7775'
    action :create
end

directory '/srv/www' do
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    action :create
end

execute 'download-wordpress' do
    command 'sudo wp core download --path="/srv/www/wordpress" --allow-root'
end

execute 'config-wordpress' do
    command 'sudo wp config create --path="/srv/www/wordpress" --dbname=wordpressdb --dbuser=wpuser --dbpass=wppsw --allow-root'
end

execute 'install-site' do
    command 'sudo wp core install --path="/srv/www/wordpress" --url="automationdeploymenttools.wordpress.com" --title="Example" --admin_user="wpuser" --admin_password="wppsw" --admin_email="laura.perez211@comunidadunir.net" --allow-root'
end

execute 'create-post' do
    command 'sudo wp post create --path="/srv/www/wordpress" --post_status="publish" --post_title="Wordpress de ejemplo" --post_content="Hola a todos" --allow-root'
end



