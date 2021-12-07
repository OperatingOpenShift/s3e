#!/bin/bash

set -x

oc apply -f 04-volumesnapshot.yaml
oc apply -f 05-backup-pvc.yaml
oc apply -f 06-pod.yaml
