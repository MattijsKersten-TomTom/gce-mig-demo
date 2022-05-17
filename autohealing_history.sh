#!/bin/bash
gcloud compute operations list --filter='operationType~compute.instances.repair.*'
