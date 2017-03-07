#!/bin/bash

#################################################
#						# 
#	These operations make the use of  	#
#	wp-cli, the WordPress management 	#
# 	tool for command-line			#
#						#
#################################################

if [ -z "$1" ]; then
	echo "Domain name cannot be empty"
	exit
else
	domainname=$1
fi

if [ -z "$2" ]; then
	sitetitle="My LampPack WordPress Website"
else
	sitetitle=$2
fi

if [ -z "$3" ]; then
	siteuser="admin"
else
	siteuser=$3
fi

if [ -z "$4" ]; then
	siteemail="wordpress@$domainname"
else
	siteemail=$4
fi

if [ -z "$5" ]; then
	sitepassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
	echo -e "\e[33mAs you didn't provide any password for admin dashboard, so please reset the password at http://$domainname/wp-admin by providing your email\e[39m"
else
	sitepassword=$5
fi

# Run spvhost and create the directory and virtual host for the domaim
domaindir=$(eval spvhost create "$domainname" 2>&1)

#cd $domaindir && rm * && wget -O wordpress.zip https://wordpress.org/latest.zip && unzip wordpress.zip && mv wordpress/* ./ && rmdir wordpress && rm wordpress.zip

# Create database and database user for WordPress
dbname=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
dbusername=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
dbpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

mysql -e "CREATE DATABASE $dbname"
mysql -e "CREATE USER '$dbusername'@'localhost' IDENTIFIED BY '$dbpassword';"
mysql -e "GRANT ALL PRIVILEGES ON * . * TO '$dbusername'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

cd "$domaindir" && wp core download --allow-root && wp core config --dbname=$dbname --dbuser=$dbusername --dbpass=$dbpassword --allow-root && wp core install --allow-root --url="$domainname" --title="$sitetitle" --admin_user="$siteuser" --admin_password="$sitepassword" --admin_email="$siteemail"

# Fix ownership and permissions
echo "Fixing permissions and ownership"
sudo chown -R www-data:www-data $domaindir
find $domaindir -type d -exec chmod 0755 {} \;
find $domaindir -type f -exec chmod 0644 {} \;
