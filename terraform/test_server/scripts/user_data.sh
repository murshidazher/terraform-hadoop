#!/bin/bash

set -eux -o

sudo yum update -y
sudo yum install -y git

# write as setup complete
sudo touch /tmp/.user-data-complete
