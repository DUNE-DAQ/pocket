from quay.io/centos/centos:stream9

USER root
#ENV HTTP_PROXY=http://np04-web-proxy.cern.ch:3128
#ENV HTTPS_PROXY=http://np04-web-proxy.cern.ch:3128
#ENV http_proxy=http://np04-web-proxy.cern.ch:3128
#ENV https_proxy=http://np04-web-proxy.cern.ch:3128

# installing deps
RUN dnf clean expire-cache ; dnf -y install python3-pip python3-devel git; dnf clean all

WORKDIR /src
RUN git clone https://github.com/eflumerf/dqm-backend.git -b eflumerf/PocketConsumer

WORKDIR /src/dqm-backend/dqm
RUN pwd; ls
RUN pip3 install --upgrade pip
RUN pip3 install -r ./requirements.txt

COPY ./entrypoint.sh /
COPY ./consumer.sh /
RUN ["chmod", "+x", "/entrypoint.sh"]
RUN ["chmod", "+x", "/consumer.sh"]
