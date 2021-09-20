from centos:8

USER root

# installing plugins
RUN dnf -y install python3-pip
RUN dnf -y install python3-devel
RUN dnf -y module enable postgresql:12
RUN dnf -y install postgresql-devel
RUN dnf -y install gcc

# copying code
COPY ./AnalysisModules /
COPY ./AnalysisServices.py /
COPY configuration.json /
COPY requirements.txt /

RUN pip3 install -r requirements.txt

COPY ./entrypoint.sh /
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]
