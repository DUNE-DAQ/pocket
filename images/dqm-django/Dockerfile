from quay.io/centos/centos:stream8

USER root

# installing deps
RUN dnf clean expire-cache ; dnf -y install python3-pip python3-devel virtualenv git; dnf clean all

WORKDIR /src
RUN git clone https://github.com/DUNE-DAQ/dqm-backend.git

WORKDIR /src/dqm-backend/dqm
RUN pwd; ls
RUN pip3 install --upgrade pip
RUN pip3 install -r ./requirements.txt

COPY ./entrypoint.sh /
RUN ["chmod", "+x", "/entrypoint.sh"]
