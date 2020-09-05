# Dockerfiles
Specs for the various containers.

## rootfs-builder
Container that generates the Debian rootfs image, installs Debian userspace and
configures the target system with files from `default-config`.

Run container:
`docker run -it -v output-dir:/app/output rootfs-builder:latest USERNAME PASSWORD [IMAGE_JSON] [MOUNT_POINT]`
