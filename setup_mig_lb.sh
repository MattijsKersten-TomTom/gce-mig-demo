#!/bin/bash

echo Creating VPC...
gcloud compute networks create web-app-vpc \
    --subnet-mode=auto

echo Creating firewall rule...
gcloud compute firewall-rules create allow-web-app-http --network web-app-vpc --allow tcp,udp,icmp,tcp:80 --source-ranges 0.0.0.0/0 

echo Creating instance template...

gcloud compute instance-templates create load-balancing-web-app-template \
    --machine-type e2-standard-2 \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --tags http-server \
    --network web-app-vpc \
    --metadata startup-script='
  sudo apt install python wget -y
  gsutil -q cp gs://mkersten/webserver.py /tmp/
  wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
  sudo python get-pip.py
  sudo python -m pip install requests
  sudo python /tmp/webserver.py &'

echo Creating RMIG...

gcloud compute instance-groups managed create load-balancing-web-app-group \
    --region europe-west1 \
    --template load-balancing-web-app-template \
    --size 6

echo Reserving global static IP for load balancer endpoint...

gcloud compute addresses create web-app-ipv4 \
    --global \
    --ip-version IPV4

echo Creating load balancer health check...

gcloud compute health-checks create http web-app-load-balancer-check \
        --port 80 \
        --request-path /health \
        --check-interval 3 \
        --timeout 3 \
        --healthy-threshold 2 \
        --unhealthy-threshold 2

echo Creating load balancer backend service...

gcloud compute backend-services create web-app-backend \
        --load-balancing-scheme=EXTERNAL \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=web-app-load-balancer-check \
        --global

echo Adding instance group to backend service...

gcloud compute backend-services add-backend web-app-backend \
        --instance-group=load-balancing-web-app-group \
        --instance-group-region=europe-west1 \
        --global

echo Creating URL map...

gcloud compute url-maps create web-app-load-balancer \
        --default-service web-app-backend

echo Creating target HTTP proxy...

gcloud compute target-http-proxies create web-app-load-balancer-target-proxy \
        --url-map=web-app-load-balancer

echo Creating global forwarding rule...

gcloud compute forwarding-rules create web-app-ipv4-frontend \
        --load-balancing-scheme=EXTERNAL \
        --address=web-app-ipv4 \
        --global \
        --target-http-proxy=web-app-load-balancer-target-proxy \
        --ports=80
