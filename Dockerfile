# Use Ubuntu 20.04 as base
FROM ubuntu:20.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install KVM and necessary packages
RUN apt-get update && \
    apt-get install -y \
        qemu-kvm \
        libvirt-daemon-system \
        libvirt-clients \
        bridge-utils \
        virtinst \
        systemd \
        sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set root password (optional)
RUN echo 'root:root' | chpasswd

# Expose libvirt port (optional, for remote management)
EXPOSE 16509

# Start a shell by default
CMD ["/bin/bash"]
