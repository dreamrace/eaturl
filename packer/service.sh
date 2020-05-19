#!/bin/bash

sudo cp /home/ec2-user/packer/eat.service /etc/systemd/system/eat.service
sudo chmod 664 /etc/systemd/system/eat.service
sudo chmod +x /home/ec2-user/packer/start.sh
sudo systemctl daemon-reload
sudo systemctl enable /etc/systemd/system/eat.service