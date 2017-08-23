#!/bin/bash
[[ -d ~/.aws ]] && rm -rf ~/.aws/config || mkdir ~/.aws
echo $'[default]\naws_access_key_id=mykey\naws_secret_access_key=mysecret\nregion=us-east-1' > .aws/config
sudo yum install -y ruby-devel gcc >/dev/null 2>&1
sudo gem install json >/dev/null 2>&1

cat <<EOF | sudo tee -a /usr/local/bin/fibsqs >/dev/null 2>&1
#!/bin/sh
while [ true ]; do
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

  message=\$(aws sqs receive-message --queue-url https://queue.amazonaws.com/acctarn/myinstance-tosolve)
  if [[ -n \$message ]]; then
    body=\$(echo \$message | ruby -e "require 'json'; p JSON.parse(gets)['Messages'][0]['Body']" | sed 's/"//g')
    handle=\$(echo \$message | ruby -e "require 'json'; p JSON.parse(gets)['Messages'][0]['ReceiptHandle']" | sed 's/"//g')
    aws sqs delete-message --queue-url https://queue.amazonaws.com/acctarn/myinstance-tosolve --receipt-handle \$handle
    echo "Solving '\${body}'."
    solved=\$(fibonacci \$body)
    parsed_solve=\$(echo \$solved | sed 's/\n/ /g')
    echo "'\${body}' solved."
    aws sqs send-message --queue-url https://queue.amazonaws.com/acctarn/myinstance-solved --message-body "\${parsed_solve}"
  fi
  sleep 1
done
EOF

chown ec2-user:ec2-user /usr/local/bin/fibsqs && chmod +x /usr/local/bin/fibsqs
