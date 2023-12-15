#!/bin/bash
##################
##
##  Universidad Internacional de la Rioja
##  Luis Garcia Garces
##
##################

# Install node js
curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash -

# Install all packages
sudo apt update
sudo apt-get install -y nodejs  nginx build-essential 

# Install pm2
sudo npm install -g pm2

# Configure Nginx
sudo systemctl enable nginx
sudo rm /etc/nginx/sites-enabled/default
sudo mv /tmp/default.conf /etc/nginx/sites-available/default
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sudo service nginx restart

# Setup firewall
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Configure pm2 to run hello on startup
mkdir -p ~/code/app-dist
mv /tmp/server.js ~/code/app-dist/server.js
cd  ~/code/app-dist/
sudo pm2 start server.js
sudo pm2 startup systemd
sudo pm2 save
sudo pm2 list

