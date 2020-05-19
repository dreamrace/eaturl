#!/bin/bash

cd /usr/local/
wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
tar -xzf go1.13.4.linux-amd64.tar.gz

cd /etc/profile.d
echo "export PATH=$PATH:/usr/local/go/bin" >> go.sh
echo "export GOPATH=$HOME/go" >> go.sh