#!/bin/bash

echo Creating health check...

gcloud compute health-checks create http autohealer-check \
    --check-interval 5 \
    --timeout 5 \
    --healthy-threshold 2 \
    --unhealthy-threshold 2 \
    --request-path "/health"

echo Creating instance template...

gcloud compute instance-templates create webserver-template \
    --machine-type e2-standard-2 \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --tags http-server \
    --metadata startup-script='
  sudo apt install python wget -y
  gsutil -q cp gs://mkersten/webserver.py /tmp/
  wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
  sudo python get-pip.py
  sudo python -m pip install requests
  sudo python /tmp/webserver.py &'

echo Creating MIG...

gcloud compute instance-groups managed create webserver-group \
    --zone europe-west1-b \
    --template webserver-template \
    --size 3 \
    --health-check autohealer-check \
    --initial-delay 90
