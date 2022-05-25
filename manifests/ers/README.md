# Pocket Error Reporting System

Setup a demo installation of DUNE DAQ ERS in KIND

## Quick-start

Make sure Docker is running and you have the needed permissions.

```
From the main Makefile:

Toggle installation of ERS by adding 'ers' to the $SERVICES variable:

SERVICES=opmon,ers make setup.local

```

Creates (in Pocket cluster):

1. namespaces
2. postgres service (one node)
4. Kafka service (one node) and topics
5. asp.net core application from https://github.com/DUNE-DAQ/daqerrordisplay


Check out the ERS service in a browser once everything is running, and apply migrations to initiate the database.

## Quick tools

Print connection and credential info
`sh .makefile/print_env.sh`

Use the kubectl and kind binaries from this environment:
`eval $(make env)`

Show pods in the application namespace:
`kubectl -n ers get pods`

Show pods in the Kafka namespace:
`kubectl -n kafka-kraft get pods`


