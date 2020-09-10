# Dockerfiles
Specs for the various containers.

## rootfs-builder
Container that generates the Debian rootfs image, installs Debian userspace and
configures the target system with files from `default-config`.

Run container:
`docker run -it --privileged -v $PWD/build/output:/app/output -v $PWD/../drm-intel:/app/drm-intel -v $PWD/../crosvm:/app/crosvm rootfs-builder:latest`
