# LampPack
A bash script to automate the installation of LAMP, phpMyAdmin, Let's Encrypt and WordPress.

### Supported OS
Ubuntu 14.04.x (both 32 bit and 64 bit) and Ubuntu 16.04.x (both 32 bit and 64 bit)

## About LampPack
LampPack is a set of some bash/shell scripts that automate several tasks together on your Ubuntu servers. If you are tired of repetitive tasks while deploying Ubuntu servers for web or if you aren't well-versed in server configuration, then these scripts are for you. Automate installation of Apache, MySQL, PHP, phpMyAdmin, Let's Encrypt (free SSL) as well as automate the deploy of WordPress for new domains. For WordPress deployment, I've used [wp-cli](https://github.com/wp-cli/wp-cli), the renowned WordPress deployment command-line tool.

## Getting started

Step 1: Clone the repo
If git isn't installed, then install it first and then clone the repo
```bash
sudo -y apt-get install git
```
and then:

```bash
git clone https://github.com/rehmatworks/lamp-pack
```
Step 2: Browse the directory
```bash
cd lamp-pack
```
Step 3: Make sp-lamp.sh executable
```bash
chmod +x sp-lamp.sh
```

Step 4: Execute the script and wait for the configuration to complete
```bash
./sp-lamp.sh
```

## Dealing with vhosts
Creating vhosts
```bash
spvhost create example.com
```

Deleting vhosts (Beware! This will delete the domain's directory with all data as well)
```bash
spvhost delete example.com
```
## Deploying WordPress (Courtesy: [wp-cli](https://github.com/wp-cli/wp-cli))
When you deploy a WordPress website, a new vhost is created. So if you have created any vhost previously, then you will have to delete it before proceeding.
```bash
 spwp example.com "Website Title" "admin_username" "admin_email" "admin_password"
```
## Installing Let's Encrypt SSL
Thanks to [Let's Encrypt](https://github.com/letsencrypt), we can install a valid SSL on unlimited domains for free! Here is what you need to do in order to install SSL on a website.
Required arguments:
1. Domain type (Maybe sub or main)
2. Domain name
3. Force SSL (optional)
```bash
spssl main example.com
```

If you want to force SSL by redirecting all HTTP requests to HTTPS, then you will have to pass the third argument as well
```bash
spssl main example.com force
```

To install the SSL on a sub-domain, pass sub as the first argument:
```bash
spssl sub blog.example.com
```
To force the SSL on a sub domain, you have to do the same as you did above
```bash
spssl sub blog.example.com force
```
