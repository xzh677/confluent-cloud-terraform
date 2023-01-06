#!/bin/bash

sudo apt update
sudo apt install -y nginx 

sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
sudo tee -a /etc/nginx/nginx.conf << END
load_module '/usr/lib/nginx/modules/ngx_stream_module.so';

events {}
stream {
  map \$ssl_preread_server_name \$targetBackend {
      default \$ssl_preread_server_name;
  }

  server {
    listen 9092; 

    proxy_connect_timeout 1s;
    proxy_timeout 7200s;

    # Run 'nslookup <ConfluentCloud_endpoint> 127.0.0.53' on nginx host to verify resolver and check /var/log/nginx/error.log for any resolving issues using 127.0.0.53
    resolver 127.0.0.53;

    # On lookup failure, reconfigure to use the cloud provider's resolver
    # resolver 169.254.169.253; # for AWS
    # resolver 168.63.129.16;  # for Azure
    # resolver 169.254.169.254;  # for Google

    proxy_pass \$targetBackend:9092;
    ssl_preread on;
  }

  server {
    listen 443;
    proxy_connect_timeout 1s;
    proxy_timeout 7200s;
    resolver 127.0.0.53; 

    proxy_pass \$targetBackend:443;
    ssl_preread on;
  }
}
END

sudo systemctl restart nginx

sudo apt install -y  openjdk-11-jdk

curl -O https://packages.confluent.io/archive/7.3/confluent-7.3.1.tar.gz
tar -zxvf confluent-7.3.1.tar.gz
tee -a /home/ubuntu/.bashrc << END
PATH=$PATH:/confluent-7.3.1/bin
END