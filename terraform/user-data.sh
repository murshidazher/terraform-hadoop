#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras enable nginx1.12
sudo yum -y install nginx
sudo mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index-orig.html
sudo bash -c 'echo "This is Nginx server from terraform passed by user-data.sh" >/usr/share/nginx/html/index.html'
sudo systemctl start nginx
