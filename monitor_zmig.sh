#!/bin/bash
while : ; do \
    gcloud compute instance-groups managed list-instances webserver-group \
    --zone europe-west1-b \
    ; done
