#!/bin/bash
oc adm policy add-scc-to-user anyuid -z default
oc project guestbook
oc apply -f redis-master-deployment.yaml
oc apply -f redis-master-service.yaml
oc apply -f redis-slave-deployment.yaml
oc apply -f redis-slave-service.yaml
oc apply -f frontend-deployment.yaml
oc apply -f frontend-service.yaml
oc get all