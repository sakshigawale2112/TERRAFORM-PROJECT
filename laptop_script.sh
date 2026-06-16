
#!/bin/bash
yum update -y
yum install nginx -y
systemctl start nginx 
systemctl enable nginx 
sudo rm -rf /usr/share/nginx/html/*
mkdir -p /usr/share/nginx/html/laptop
echo "<h1>welcome to laptop store</h1>" > /usr/share/nginx/html/laptop/index.html
systemctl restart nginx
