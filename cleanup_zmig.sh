#!/bin/bash
gcloud compute instance-groups managed delete webserver-group --zone europe-west1-b -q
gcloud compute instance-templates delete webserver-template -q
gcloud compute health-checks delete autohealer-check -q
