FROM debian:buster-slim

RUN apt-get update
RUN apt-get install -y multistrap binfmt-support qemu-user-static python3 debootstrap
RUN mkdir -p /app/{debian-rootfs,scripts,output,config}
COPY debian-rootfs/ /app/debian-rootfs/
COPY config/ /app/config/
COPY scripts/ /app/scripts/
COPY run.sh /app/
RUN mkdir -p /app/{output,mount}

WORKDIR /app/
USER root
ENTRYPOINT [ "/bin/bash", "/app/run.sh" ]