#!/bin/bash
cd /tmp
curl https://amazon-ssm-us-west-2.s3.amazonaws.com/latest/debian_amd64/amazon-ssm-agent.deb -o amazon-ssm-agent.deb >> ./user-script.log || halt
dpkg -i amazon-ssm-agent.deb >> ./user-script.log || halt
start amazon-ssm-agent >> ./user-script.log || halt
