#!/bin/bash

pghost=$(aws ssm get-parameters --name alpha.postgresql.endpoint --region ap-southeast-1 | jq -r '.Parameters[0].Value')
redis=$(aws ssm get-parameters --name alpha.redis --region ap-southeast-1 | jq -r '.Parameters[0].Value')
pass=$(aws ssm get-parameters --name alpha.postgresql.pass --region ap-southeast-1 --with-decryption | jq -r '.Parameters[0].Value')
export POSTGRESQL_CONNECTION_STRING="postgres://postgres:$pass@$pghost/postgres?sslmode=disable"
export RADIS_HOSTNAME="$redis"
exec /home/ec2-user/app/eaturl