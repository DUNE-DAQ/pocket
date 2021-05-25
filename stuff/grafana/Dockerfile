from grafana/grafana:7.5.7

USER root

# installing plugins
RUN apk add --no-cache curl unzip

COPY dashboards /opt/grafana/dashboards

# example dashboard: node-exporter
# RUN curl -Lo /opt/grafana/dashboards/node_exporter.json https://grafana.com/api/dashboards/1860/revisions/23/download

# example plugin: aceiot-svg-panel
RUN curl -Lo aceiot.zip https://grafana.com/api/plugins/aceiot-svg-panel/versions/0.0.8/download && \
    unzip aceiot.zip > /dev/null && \
    mkdir /var/lib/grafana/plugins/aceiot-svg-panel && \
    mv ACE-IoT-Solutions-ace-svg-react-* /var/lib/grafana/plugins/aceiot-svg-panel && \
    rm -rf aceiot.zip ACE-IoT-Solutions-ace-svg-react-*

# copying confs
COPY conf /etc/grafana

USER grafana
