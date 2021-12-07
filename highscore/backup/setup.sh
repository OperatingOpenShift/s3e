#!/bin/bash

set -x

oc apply -f 01-namespace.yaml
oc project arcade
oc new-app --name=game --context-dir=game https://github.com/NautiluX/s3e
oc new-app --name=highscore --context-dir=highscore https://github.com/NautiluX/s3e
DOMAIN=$(oc get ingresses.config.openshift.io  cluster -o jsonpath='{.spec.domain}')
oc expose svc game --path=/s3e --hostname=arcade.$DOMAIN
oc expose svc highscore --path=/highscore --hostname=arcade.$DOMAIN
oc apply -f 02-persistentvolumeclaim.yaml
oc apply -f 03-deployment.yaml
