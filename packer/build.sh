#!/bin/bash

cd ~/app
go mod vendor
go build -o eaturl
chmod +x eaturl
ls -al