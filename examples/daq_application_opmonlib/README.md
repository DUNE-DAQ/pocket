# Running a DAQ Application in Pocket and retrieving monitoring data

In this example we will start a container, get a shell to it, 
set up a v2.6.0 development environment, and run a `daq_application`.

Additionally, we will configure the opmonlib reverse proxy
and direct our `daq_application`s monitoring data to it.

## Where can I run this?
Any linux machine that has a functional installation of docker. (yes, this could be your laptop).

## Starting pocket

In case you haven't got a copy of pocket yet:
```bash
# get your copy of Pocket
git clone https://github.com/DUNE-DAQ/pocket.git
cd pocket
# (optional) make your shell use binaries (kubectl, ...) that pocket ships with
eval $(make env)
```

```bash
# in this example, we only need opmon services in Pocket
SERVICES=opmon make setup.local
```

This command will fail if you already have a cluster setup.  
In case opmon services aren't present in the existing cluster,
or if you're not sure, run `SERVICES=opmon make kubectl-apply`

## Starting containers and getting a shell

```bash
cd examples/daq_application_opmonlib

# start reverse proxy and linux container
kubectl apply -f opmonlib-proxy.yaml -f daq_application_manually.yaml

# wait for the container to be ready, then open a shell
kubectl wait --for=condition=ready --timeout=180s pod example-daq-app-manually
kubectl exec -it example-daq-app-manually -- bash
```

```bash
source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh
setup_dbt dunedaq-v2.6.0

mkdir workdir
cd workdir
dbt-create.sh dunedaq-v2.6.0 exampleapp
cd exampleapp

dbt-workarea-env

curl -LO https://raw.githubusercontent.com/DUNE-DAQ/listrev/develop/test/list-reversal-app.json

daq_application -n batman -c stdin://list-reversal-app.json -i 'influx://opmonlib-proxy.monitoring:80/write?db=influxdb'
```

## Viewing data in InfluxDB

Leave the daq_application open if you like, but let it run for a minute or so for influxdb data to be pushed.

Open a shell to the InfluxDB container.
```bash
$ kubectl -n monitoring get pod -l app=influxdb
NAME                        READY   STATUS    RESTARTS   AGE
influxdb-5f875748d6-xx9x6   1/1     Running   0          28m
$ kubectl -n monitoring exec -it influxdb-5f875748d6-xx9x6 -- bash
$ influx
Connected to http://localhost:8086 version 1.8.6
InfluxDB shell version: 1.8.6
$ use database influxdb
$ show measurements
name: measurements
name
----
cpu
disk
diskio
dunedaq.appfwk.appinfo.Info
dunedaq.rcif.runinfo.Info
kernel
mem
net
netstat
processes
swap
system
$ select * from "dunedaq.appfwk.appinfo.Info"
name: dunedaq.appfwk.appinfo.Info
time                busy  error source_id     state
----                ----  ----- ---------     -----
1622811152000000000 false false global_batman NONE
1622811162000000000 false false global_batman NONE
1622811172000000000 false false global_batman NONE
1622811182000000000 false false global_batman NONE
1622811192000000000 false false global_batman NONE
$ select * from "dunedaq.rcif.runinfo.Info"
name: dunedaq.rcif.runinfo.Info
time                running runno runtime source_id
----                ------- ----- ------- ---------
1622811152000000000 false   0     0       global_batman
1622811162000000000 false   0     0       global_batman
1622811172000000000 false   0     0       global_batman
1622811182000000000 false   0     0       global_batman
1622811192000000000 false   0     0       global_batman
1622811202000000000 false   0     0       global_batman
```