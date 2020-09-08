FROM debian:buster-slim

RUN apt-get update
RUN apt-get install -y binfmt-support python3 debootstrap
RUN mkdir -p /app/{scripts,output,config}
COPY config/ /app/config/
COPY scripts/ /app/scripts/
COPY run.sh /app/
RUN mkdir -p /app/{output,mount}

WORKDIR /app/
USER root
ENTRYPOINT [ "/bin/bash", "/app/run.sh" ]