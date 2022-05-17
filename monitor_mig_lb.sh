#!/bin/bash
FE_CONFIG=$(gcloud compute forwarding-rules describe web-app-ipv4-frontend --global)
IP=$(echo -n "$FE_CONFIG" | grep "IPAddress" | awk '{print $2}')
echo Frontend IP is $IP

while true
do
        BODY=$(curl -s "$IP")
        NAME=$(echo -n "$BODY" | grep "load-balancing-web-app-group" | perl -pe 's/.+?load-balancing-web-app-group-(.+?)<.+/\1/')
        ZONE=$(echo -n "$BODY" | grep "europe-" | perl -pe 's/.+?europe-(.+?)<.+/\1/')

        echo Instance $NAME in $ZONE
done
