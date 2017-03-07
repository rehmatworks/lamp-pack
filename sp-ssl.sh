#!/bin/bash

############################################
#	Author:	Rehmat (https://rehmat.works)  #
#	For: ServerPack.io					   #
#	Description: A bash script to install  #
#	Lets Encrypt SSL certificates on Ubuntu#
#	servers								   #
############################################

domainType=$1
domain=$2
forceSSL=$3
req_lib='letsencrypt'

if ! type "$req_lib" > /dev/null; then
  apt-get -y install letsencrypt letsencrypt-* &> /dev/null
fi

if [ "$domain" != '' ]; then
	if [ "$domainType" == 'main' ]; then
		if [ "$forceSSL" != 'force' ]; then
			thecommand="letsencrypt --apache --register-unsafely-without-email --non-interactive --agree-tos --no-redirect -d $domain -d www.$domain"
		else
			thecommand="letsencrypt --apache --register-unsafely-without-email --non-interactive --agree-tos --redirect -d $domain -d www.$domain"
		fi
	else
		if [ "$forceSSL" != 'force' ]; then
			thecommand="letsencrypt --apache --register-unsafely-without-email --non-interactive --agree-tos --no-redirect -d $domain"
		else
			thecommand="letsencrypt --apache --register-unsafely-without-email --non-interactive --agree-tos --redirect -d $domain"
		fi
	fi
	output=$(eval $thecommand 2>&1)
	sudo service apache2 reload
	if [[ "$output" == *"Congratulations"* ]]; then
		echo -e "\e[32mSSL certificate installed successfully!\e[39m"
	elif [[ "$output" == *"too many requests"* ]]; then
		echo -e "\e[31mLet's Encrypt SSL limit reached. Please wait for a few days before obtaining more SSLs for $domain\e[39m"
	elif [[ "$output" == *"No vhost exists with servername"* ]]; then
		echo -e "\e[31mSeems like this domain hasn't been added to Apache vhosts yet\e[39m"
	else
		echo $output
	fi
else
	echo -e "\e[31mPlease provide domain name\e[39m"
fi