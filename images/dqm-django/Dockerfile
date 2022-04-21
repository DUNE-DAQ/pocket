from quay.io/centos/centos:stream8

USER root

# installing deps
#RUN dnf clean expire-cache ; dnf -y install python3-pip python3-devel virtualenv git; dnf clean all
RUN dnf clean expire-cache ; dnf -y install python3-pip python3-devel virtualenv ; dnf clean all

WORKDIR /src
#RUN git clone https://github.com/DUNE-DAQ/dqm-backend.git
COPY ./dqm/ ./

WORKDIR /src/
RUN pwd; ls
RUN pip3 install --upgrade pip
RUN pip3 install -r ./requirements.txt

COPY ./entrypoint.sh /
RUN ["chmod", "+x", "/entrypoint.sh"]
#WORKDIR /src/dqm
#ENTRYPOINT ["/usr/local/bin/daphne dqm.asgi:application -b 0.0.0.0 -p 8000"]
#ENTRYPOINT ["/bin/bash"]
