# Pocket Data Quality Monitoring

Setup a demo installation of DUNE DAQ DQM in KIND

## Quick-start

Make sure Docker is running and you have the needed permissions.

```
From the main Makefile:

Toggle installation of DQM by adding 'dqm' to the $SERVICES variable:

SERVICES=opmon,dqm make setup.local

```

Creates (in Pocket cluster):

1. namespaces
2. postgres service (one node)
4. Kafka service (one node) and topics
5. asp.net core application from https://github.com/DUNE-DAQ/dqmplatform
6. python Analysis module container in the same pod as aspcore DQM


Check out the DQM service in a browser once everything is running, and apply migrations to initiate the database.

## Quick tools

Print connection and credential info
`sh .makefile/print_env.sh`

Use the kubectl and kind binaries from this environment:
`eval $(make env)`

Show pods in the application namespace:
`kubectl -n dunedaqers get pods`

Show pods in the Kafka namespace:
`kubectl -n kafka-kraft get pods`


