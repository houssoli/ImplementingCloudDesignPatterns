#!/bin/bash
mkdir /var/log/test
for i in {1..4}; do for j in {1..100}; do  uuidgen >>/var/log/test/stuff.log; done; sleep 75; done
ls -alh /var/log/test
