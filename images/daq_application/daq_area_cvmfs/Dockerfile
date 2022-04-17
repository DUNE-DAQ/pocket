# syntax=docker/dockerfile:1
FROM docker.io/dunedaq/c8-minimal:latest

SHELL ["/bin/bash", "-c"] 

RUN mkdir -p /dunedaq/

ADD ./image /dunedaq/run

COPY ./common/app-entrypoint.sh /dunedaq/run

RUN chmod 755 /dunedaq/run/app-entrypoint.sh

ENTRYPOINT [ "/dunedaq/run/app-entrypoint.sh" ]
