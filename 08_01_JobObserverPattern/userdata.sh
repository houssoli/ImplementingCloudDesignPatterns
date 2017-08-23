#!/bin/bash
[[ -d /home/ec2-user/.aws ]] && rm -rf /home/ec2-user/.aws/config || mkdir /home/ec2-user/.aws
echo $'[default]\naws_access_key_id=mykey\naws_secret_access_key=mysecret\nregion=us-east-1' > /home/ec2-user/.aws/config
chown ec2-user:ec2-user /home/ec2-user/.aws -R
cat <<EOF >/usr/local/bin/fibsqs
#!/bin/sh
function fibonacci {
  a=1
  b=1
  i=0

  while [ \$i -lt \$1 ]
  do
    printf "%d\n" \$a
    let sum=\$a+\$b
    let a=\$b
    let b=\$sum
    let i=\$i+1
  done
}

number="\$1"

solved=\$(fibonacci \$number)
parsed_solve=\$(echo \$solved | sed 's/\n/ /g')
aws sqs send-message --queue-url https://queue.amazonaws.com/acctarn/myinstance-solved --message-body "\${parsed_solve}"
exit 0
EOF
chown ec2-user:ec2-user /usr/local/bin/fibsqs
chmod +x /usr/local/bin/fibsqs
yum install -y libxml2 libxml2-devel libxslt libxslt-devel gcc ruby-devel >/dev/null 2>&1
gem install nokogiri -- --use-system-libraries >/dev/null 2>&1
gem install shoryuken >/dev/null 2>&1
cat <<EOF >/home/ec2-user/config.yml
aws:
  access_key_id:      mykey
  secret_access_key:  mysecret
  region:             us-east-1 # or <%= ENV['AWS_REGION'] %>
  receive_message:
    attributes:
      - receive_count
      - sent_at
concurrency: 25,  # The number of allocated threads to process messages. Default 25
delay: 25,        # The delay in seconds to pause a queue when it's empty. Default 0
queues:
  - [myinstance-tosolve-priority, 2]
  - [myinstance-tosolve, 1]
EOF
cat <<EOF >/home/ec2-user/worker.rb
class MyWorker
  include Shoryuken::Worker

  shoryuken_options queue: 'myinstance-tosolve', auto_delete: true

  def perform(sqs_msg, body)
    puts "normal: #{body}"
    %x[/usr/local/bin/fibsqs #{body}]
  end
end

class MyFastWorker
  include Shoryuken::Worker

  shoryuken_options queue: 'myinstance-tosolve-priority', auto_delete: true

  def perform(sqs_msg, body)
    puts "priority: #{body}"
    %x[/usr/local/bin/fibsqs #{body}]
  end
end
EOF
chown ec2-user:ec2-user /home/ec2-user/worker.rb /home/ec2-user/config.yml
screen -dm su - ec2-user -c 'shoryuken -r /home/ec2-user/worker.rb -C /home/ec2-user/config.yml'
