#!/bin/bash

sed -i "s/\"Password\"\:\"Secret from Kubernetes\!\"/\"Password\"\:\"${PGPASS}\"/g" configuration.json
exec python3 AnalysisServices.py
