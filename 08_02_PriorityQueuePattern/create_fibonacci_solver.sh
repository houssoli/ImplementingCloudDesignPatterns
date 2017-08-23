#!/bin/bash
[[ -d ~/.aws ]] && rm -rf ~/.aws/config || mkdir ~/.aws
echo $'[default]\naws_access_key_id=mykey\naws_secret_access_key=mysecret\nregion=us-east-1' > .aws/config
cat <<EOF | sudo tee -a /usr/local/bin/fibsqs >/dev/null 2>&1
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
sudo chown ec2-user:ec2-user /usr/local/bin/fibsqs && sudo chmod +x /usr/local/bin/fibsqs
