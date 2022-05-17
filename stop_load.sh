#!/bin/bash
export MACHINES=$(gcloud compute instances list --format="csv[no-heading](name,networkInterfaces[0].accessConfigs[0].natIP)" | grep "webserver-group")
for i in $MACHINES;
do
  NAME=$(echo "$i" | cut -f1 -d,)
  IP=$(echo "$i" | cut -f2 -d,)
  echo "Simulating low load for instance $NAME"
  curl -q -s "http://$IP/stopLoad" >/dev/null --retry 2
done
