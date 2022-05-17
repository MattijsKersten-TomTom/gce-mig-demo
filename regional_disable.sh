#!/bin/bash
if [ $# -eq 0 ]; then
    echo "$(basename $0): Please provide zone as the argument"
    exit 1
fi

MACHINES=$(gcloud compute instances list --filter="zone:($1)" --format="csv[no-heading](name,networkInterfaces[0].accessConfigs[0].natIP)" )
for i in $MACHINES;
do
	NAME=$(echo "$i" | cut -f1 -d,)
	IP=$(echo "$i" | cut -f2 -d,)
	echo "Simulating zone failure for $NAME"
	curl -q "http://$IP/makeUnhealthy"
done
