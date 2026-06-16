#!/bin/bash
yum update -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx
sudo rm -rf /usr/share/nginx/html/*
mkdir -p /usr/share/nginx/html/cloth
echo "<h1>welcome to cloth store</h1>" > /usr/share/nginx/html/cloth/index.html
echo "<h1>welcome to cloudblitz</h1>" > /usr/share/nginx/html/index.html
systemctl restart nginx
