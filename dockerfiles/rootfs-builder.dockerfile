FROM ubuntu:focal

RUN apt-get install multistrap binfmt-support qemu-user-static python3 debootstrap
RUN mkdir -p /app/{debian-rootfs,scripts,output,config}
COPY debian-rootfs/ /app/debian-rootfs/
COPY default-config/ /app/config/
COPY run.sh /app/

ENTRYPOINT [ "run.sh" ]