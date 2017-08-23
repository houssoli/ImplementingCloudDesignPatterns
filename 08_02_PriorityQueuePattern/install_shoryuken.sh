#!/bin/bash
sudo yum install -y libxml2 libxml2-devel libxslt libxslt-devel gcc ruby-devel >/dev/null 2>&1
sudo gem install nokogiri -- --use-system-libraries >/dev/null 2>&1
sudo gem install shoryuken >/dev/null 2>&1
