#!/bin/bash
[[ -d ~/.aws ]] && rm -rf ~/.aws/config || mkdir ~/.aws
echo $'[default]\naws_access_key_id=mykey\naws_secret_access_key=mysecret\nregion=us-east-1' > .aws/config

for i in {1..100}; do
  value=$(shuf -i 1-50 -n 1)
  aws sqs send-message \
    --queue-url https://queue.amazonaws.com/acctarn/myinstance-tosolve \
    --message-body ${value} >/dev/null 2>&1
done
