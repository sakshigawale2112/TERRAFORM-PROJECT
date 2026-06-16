#!bin/bash
apt update
apt install nginx -y
systemctl start nginx
mkdir -p /var/www/html/cloth
echo "<h1>welcome to cloth<h1>" > /var/www/html/cloth/index.html
