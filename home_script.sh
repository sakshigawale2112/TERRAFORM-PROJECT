#!/bin/bash
yum update -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx
sudo rm -f /usr/share/nginx/html/*
echo "<h1>Welcome to cloudblitz</h1>" > /usr/share/nginx/html/index.html
systemctl restart nginx

