#!/bin/bash
MACHINES=$(gcloud compute instances list --format="csv[no-heading](name,networkInterfaces[0].accessConfigs[0].natIP)")
for i in $MACHINES;
do
	NAME=$(echo "$i" | cut -f1 -d,)
	IP=$(echo "$i" | cut -f2 -d,)
	echo "Reseting health and load on VM $NAME ($IP)"
	curl -q "http://$IP/makeHealthy" 2>/dev/null
	curl -q "http://$IP/stopLoad" 2>/dev/null
done
