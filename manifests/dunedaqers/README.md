# Pocket

Setup a demo installation of DUNE DAQ ERS in KIND

## Quick-start

Make sure Docker is running and you have the needed permissions.

```
From the main Makefile:
make ers-kafka.local
```

Creates:

1. proxy server
2. namespaces
3. postgres service (one node)
4. Kafka service (one node)
5. asp.net core application from https://github.com/DUNE-DAQ/daqerrordisplay

```
make topics
```
Will configure the Kafka topic erskafka-reporting

Check out the ERS service in a browser once everything is running, and apply migrations to initiate the database.

## Quick tools

Show pods in the application namespace:
`kubectl -n dunedaqers get pods`

Show pods in the Kafka namespace:
`kubectl -n kafka-kraft get pods`


