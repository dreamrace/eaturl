Response by King Li

## Question 1

Assumptions:
- Standard linux platform
- gnu utils, jq, geoiplookup commands are installed host executing these codes

### Part 1

    Count​ the total​ number​​of HTTP​ requests​ recorded​ by​ this​ access​ logfile

```bash
$ wc -l < access.log
86084
```

### Part 2

    Find​ the top-10​ (host)​ hosts​ makes​ most​ requests​ from​ 2019-06-10​ 00:00:00​ to2019-06-19​ 23:59:59,​ inclusively

```bash
$ awk '$4>"[10/Jun/2019:00:00:" && $4<"[19/Jun/2019:23:59:99"' < access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10 | awk '{print $2}'
1.222.44.52
118.24.71.239
119.29.129.76
148.251.244.137
95.216.38.186
136.243.70.151
213.239.216.194
5.9.71.213
5.189.159.208
5.9.108.254
```

### Part 3

    Find​ out the​ country​ with​ most​ requests​ originating​ from​ (according​​to the source​IP)


```bash
$ cat access.log | awk '{print $1}' | xargs -n 1 geoiplookup {} | awk -F": " '$2 !~ /can/' | sed -r 's/GeoIP Country( V6)? Edition: //g' | sort -rn | uniq -c | sort -nr | head -n 1
29049 US, United States
```

## Question 2

    A script to query EC2 API, discover public ip for a given name tag, then initiate ssh to the host

```bash
#!/bin/bash
# AWS SSH
if [ -z "$1" ]
then 
    echo "Please enter a name"
    exit 1
fi
resp=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$1 | jq -r ".Reservations[].Instances[].PublicIpAddress")
if [ -z "$resp" ]
then
    echo "Host not found"
    exit 1
fi
ssh ec2-user@$resp
```

Script also supplied at `./awsssh.sh`
JQ is needed in order to execute the script

```bash
$ ./awsssh.sh testtesttest
ec2-user@****************

$ ./awsssh.sh not-found-host
Host not found

$ ./awsssh.sh
Please enter a name
```

Question 3

    To design and implement a url shortener service

Goals:
- High availiable
- Scalable

Stack requirement
- Any AWS technology
- Code hosted on Generic Linux EC2
- No container orchastraction (as per email discussion)

Implementation components
- API server in golang
  - Simple http server in golang with 2 API
  - Packer used to package code into AMI
  - Systemd service used to start application at startup
  - Configuration pulled from SSM at startup
- Infrastructure
  - Load balancer to accept external connection
  - PostgreSQL database RDS running in multi-az mode (Automatic failover)
  - ElasticCache Redis running in multi-az mode with multiple nodes
  - Configuration and credentials managed by SSM Parameter store
  - All infrastructure is deployed with Terraform

High availiability

In the deployment files, we have specified 2 az for any piece of infrastructure to reside in, garentee that in event of any single-zone failure, there will be no distruption to service.

Database deployed in RDS is in 2 nodes mode, in event of a failure in any database, the reader/slave node will take the place of the master node and continue service for the systems.
