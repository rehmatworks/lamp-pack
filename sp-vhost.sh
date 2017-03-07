#!/bin/bash
theAction=$1
domainName=$2
directoryName="/var/www/$domainName"

if [ -z "$domainName" ]
	then
	echo -e "\e[31mPlease provide the domain name\e[39m"
	exit 
fi
if [ -z "$theAction" ]
	then
	echo -e "\e[31mAction not provided, it must be either create or delete\e[39m"
	exit
fi

if [ "$theAction" == "create" ]
	then

	if [ -d "$directoryName" ]
		then
		echo -e "\e[31mDirectory already exists. If not required, please delete first\e[39m"
		exit 
	fi
	sudo mkdir $directoryName
	sudo echo "<VirtualHost *:80>
	ServerName $domainName
	DocumentRoot \"$directoryName/\"
	<Directory \"$directoryName\">
		Options FollowSymLinks
		AllowOverride All
		Order allow,deny
		Allow from all
	</Directory>
</VirtualHost>" > /etc/apache2/sites-available/$domainName.conf
	sudo echo "<?php phpinfo();?>" > "$directoryName/phpinfo.php"
	sudo echo '<!DOCTYPE html>
<html>
	<head>
		<title>Your LampPack Website is Ready</title>
		<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
		<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">
		<link href="https://fonts.googleapis.com/css?family=Varela+Round" rel="stylesheet" type="text/css">
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
	</head>
	<style>
		html,
		body {
		  padding: 10px;
		  font-family: "Varela Round";
		  background:#B2B2B2;
		}
		a {
		  color: #aaaaaa;
		  transition: all ease-in-out 200ms;
		}
		a:hover {
		  color: #333333;
		  text-decoration: none;
		}
		.sp-para {
		  color: #F0F0F0;
		  padding: 10px 20px;
		}
		.sp-para p {
		  margin-bottom: 5px;
		}
		.logo {
		  padding: 15px 0;
		  font-size: 25px;
		  color: #F0F0F0;
		  font-weight: bold;
		}
		.credit {
			color: #F0F0F0;
			font-size: 12px;
			font-style: italic;
		}
	</style>
	<body>
		<div class="text-center" style="padding:200px 0">
		    <div class="logo">Hurrah! Your Website is Ready</div>
			<div class="col-md-8 col-md-offset-2">
				<div class="sp-para">
					<p>Now its time to sign in via SFTP and start uploading your real website files by deleting this one. If you are not sure how to do this, then please check <a style="color:#ffffff;" href="https://github.com/rehmatworks/lamp-pack">GitHub page</a>.</p>
				</div>
				<div class="credit">Server proudly configured by LampPack by Rehmat</div>
			</div>
		</div>
	</body>
</html>' > "$directoryName/index.php"
	sudo a2ensite $domainName &>/dev/null
	sudo chmod -R $directoryName &>/dev/null
	sudo chown -R www-data:www-data $directoryName &>/dev/null
	echo $directoryName
elif [ "$theAction" == "delete" ]
	then
	if [ -f "/etc/apache2/sites-enabled/$domainName.conf" ]
		then
		sudo a2dissite $domainName &>/dev/null
		sudo rm -r $directoryName
		sudo rm /etc/apache2/sites-available/$domainName.conf
		echo -e "\e[32mThe website $domainName deleted!\e[39m"
	else
		echo -e "\e[31mWe did not find vhost of $domainName\e[39m"
		exit
	fi
else
	echo -e "\e[31mThe action not recognized!\e[39m"
	exit
fi
sudo service apache2 reload &>/dev/null
