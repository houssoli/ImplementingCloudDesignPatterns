#!/bin/bash
shoryuken -r /home/ec2-user/worker.rb -C /home/ec2-user/config.yml >output.log
cat output.log | grep -E '^normal:|^priority:' >parsed_output.log
