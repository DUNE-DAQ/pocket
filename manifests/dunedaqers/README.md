# Pocket

Setup a demo installation of DUNE DAQ ERS in KIND

## Quick-start

Make sure Docker is running and you have the needed permissions.
i
```
sh run.sh
```

Creates:

1. proxy server
2. namespaces
3. postgres service (one node)
4. Kafka service (one node)
5. asp.net core application from https://github.com/DUNE-DAQ/daqerrordisplay

(no topics configured)
