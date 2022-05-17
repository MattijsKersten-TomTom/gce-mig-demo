#!/bin/bash
while : ; do \
    gcloud compute instance-groups managed list-instances webserver-group \
    --region europe-west1 \
    ; done
