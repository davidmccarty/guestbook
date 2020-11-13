#!/bin/bash
echo "Deleting the namespace guestbook - dont forget to start kubectl proxy"
oc project guestbook
oc delete --all all,secret,pvc > /dev/null
oc get ns guestbook -o json > tempfile
sed -i '' '/"kubernetes"/d' ./tempfile
curl --silent -H "Content-Type: application/json" -X PUT --data-binary @tempfile http://127.0.0.1:8001/api/v1/namespaces/guestbook/finalize
oc get all