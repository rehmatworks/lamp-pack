#!/bin/bash

#########################################################
#							#
#	Package Name: LampPack				#
#	Author: Rehmat Alam (https:rehmat.works)	#
#	Description: LampPack allows you to		#
#	automate the installation of LAMP stack		#
# 	and many other utilities on Ubuntu 		#
#							#
#########################################################

echo ''
echo -e "\e[32mWelcome to LampPack LAMP automation bash script\e[39m"
echo ''
sleep 1
echo -e "\e[32mPlease sit back and relax while LampPack configures your server, this may take several minutes\e[39m"

echo ''

sleep 3

# Check if is root or not
if [ "$EUID" -ne 0 ]
  then
  	echo -e "\e[31mError! You must run this as root user\e[39m"
  exit
fi

# Install sudo if missing
if ! hash sudo 2>/dev/null; then
	apt-get update -y &>/dev/null
	apt-get install sudo
	exit
fi

echo 'Checking OS compatibility'
echo ''

cmd="lsb_release -d"
output=$(eval $cmd 2>&1)
os=${output//[[:blank:]]/}
os=${os#*:}
bitversion=$(eval "getconf LONG_BIT")

# Define an array of supported OS
allowedOS=("Ubuntu16.04.1LTS" "Ubuntu14.04.5LTS"
"Ubuntu14.04.4LTS" "Ubuntu16.04.2LTS" "Ubuntu16.04LTS")

# Check if it supports the OS then proceed
# else exit

if [[ " ${allowedOS[@]} " =~ " ${os} " ]]; then

	# Provide credentials for MySQL and PHPMyAdmin
	ROOT_PASS=`date +%s|sha256sum|base64|head -c 15`
	APP_DB_PASS=`date +%s|sha256sum|base64|head -c 15`
	PMA_PASS=`date +%s|sha256sum|base64|head -c 15`

	sudo echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
	sudo echo "phpmyadmin phpmyadmin/app-password-confirm password $PMA_PASS" | debconf-set-selections
	sudo echo "phpmyadmin phpmyadmin/mysql/admin-pass password $ROOT_PASS" | debconf-set-selections
	sudo echo "phpmyadmin phpmyadmin/mysql/app-pass password $APP_DB_PASS" | debconf-set-selections
	sudo echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	sudo echo "mysql-server mysql-server/root_password password $ROOT_PASS" | sudo debconf-set-selections
	sudo echo "mysql-server mysql-server/root_password_again password $ROOT_PASS" | sudo debconf-set-selections

	if hash mysql 2>/dev/null; then
		echo -e "\e[31mWe detected that MySQL is already installed. Only clean servers are supported\e[39m"
		echo ''
	elif hash apache2 2>/dev/null; then
		echo -e "\e[31mWe detected that Apache server is already installed. Only clean servers are supported\e[39m"
		echo ''
	elif hash php 2>/dev/null; then
		echo -e "\e[31mWe detected that PHP is already installed. Only clean servers are supported\e[39m"
		echo ''
	else

		# Run an update and upgrade for packages
		echo "Checking for available software updates"
		echo ''
		sudo apt-get update -y &>/dev/null
		echo "Applying critical updates"
		echo ''
		sudo apt-get upgrade -y  &>/dev/null

		# Install essential dependencies
		echo "Installing essential dependencies"
		echo ''
		sudo apt-get install -y build-essential  &>/dev/null

		# Install AMP + PHPMyAdmin
		echo "Installing LAMP server and phpMyAdmin"
		echo ''
		sudo apt-get -y install lamp-server^ phpmyadmin  &>/dev/null

		# Install PHP modules
		sudo apt-get -y install php-mcrypt php-zip php-mbstring &>/devnull

		# Install ZIP
		sudo apt-get -y install zip  &>/dev/null

		# Install sendmail
		echo "Installing sendmail"
		echo ''
		sudo apt-get -y install sendmail  &>/dev/null

		# Enabling modules
		echo "Enabling Apache modules"
		echo ''
		sudo a2enmod rewrite  &>/dev/null

		# Install Lets Encrypt
		echo "Installing additional dependencies"
		echo ''
		sudo apt-get install -y libxml2-dev mysql-client libfreetype6-dev libssl-dev libcurl4-openssl-dev pkg-config libbz2-dev libjpeg-dev libpng-dev libmcrypt-dev libmysqlclient-dev &>/dev/null

		echo "Installing Let's Encrypt libraries"
		echo ''
		if ! hash letsencrypt 2>/dev/null; then
			lecheck=$(eval "apt-cache show letsencrypt 2>&1")
			if [[ "$lecheck" == *"No"* ]]
				then
				sudo wget --no-check-certificate https://dl.eff.org/certbot-auto  &>/dev/null
				sudo chmod a+x certbot-auto  &>/dev/null
				sudo mv certbot-auto /usr/local/bin/letsencrypt  &>/dev/null
			else
				sudo apt-get install -y letsencrypt letsencrypt-*  &>/dev/null
			fi
		fi

		# Install WP-CLI to manage WordPress sites
		echo "Installing WP-CLI for WordPress management"
		echo ''
		sudo wget --no-check-certificate -O wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &>/dev/null
		sudo chmod +x wp-cli.phar &>/dev/null
		sudo mv wp-cli.phar /usr/local/bin/wp  &>/dev/null

		# Import vhost creation bash script
		echo "Configuring LampPack core utilities"
		echo ''
		sudo mv sp-vhost.sh /usr/local/bin/spvhost &>/dev/null
		sudo chmod +x /usr/local/bin/spvhost  &>/dev/null

		# Import ssl management bash script
		sudo mv sp-ssl.sh /usr/local/bin/spssl &>/dev/null
		sudo chmod +x /usr/local/bin/spssl  &>/dev/null

		# Import WordPress installation script
		sudo mv sp-wordpress.sh /usr/local/bin/spwp &>/dev/null
		sudo chmod +x /usr/local/bin/spwp  &>/dev/null
		
		# Delete apache default conf
		sudo rm /etc/apache2/sites-available/* &>/dev/null
		sudo rm /etc/apache2/sites-enabled/* &>/dev/null
		
		# Restart Apache
		echo -e "\e[33mReloading and restarting Apache server\e[39m"
		echo ''
		sudo service apache2 reload &>/dev/null
		sudo service apache2 restart  &>/dev/null

		# Enable auto upgrades
		echo "Enabling automatic software updates"
		echo ''
		sudo apt-get install -y unattended-upgrades  &>/dev/null
		sudo dpkg-reconfigure -p critical unattended-upgrades  &>/dev/null
		sudo service apache2 restart  &>/dev/null

		# Clean junk
		echo -e "\e[33mCleaning junk and completing the installation\e[39m"
		echo ''
		sudo apt-get -y autoremove  &>/dev/null
		sudo chmod -R 0755 /var/www &>/dev/null
		sudo chown -R www-data:www-data /var/www &>/dev/null

		# Save the MySQL root password in .my.cnf]
		sudo echo "[client]
		user=root
		password=$ROOT_PASS" > /root/.my.cnf

		echo -e "\e[32mInstallation completed!\e[39m"
		echo ''
	fi
else
	echo -e "\e[31mIncompatible operating system detected. Only selected releases of Ubuntu are supported\e[39m"
fi
