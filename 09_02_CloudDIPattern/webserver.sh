#!/bin/sh
yum groupinstall -y "Web Server" "PHP Support"
aws s3 cp s3://houssoli-1ce8b98d-8735-47ff-a9dc-7f4b57820a74/index.php /var/www/html/index.php
service httpd start
