#!/bin/bash

sudo yum update -y
sudo yum install httpd -y

sudo systemctl start httpd
sud0 systemctl enable httpd

sudo bash -c 'echo "<h1>Example Application Host</h1>" >/var/www/html/index.html'
