FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        qemu-system-x86 qemu-utils cloud-image-utils wget openssh-client sudo vim && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /vms /cloud-init

# Copy scripts
COPY start-vm.sh /start-vm.sh
COPY cloud-init/ /cloud-init/

WORKDIR /vms

ENTRYPOINT ["/start-vm.sh"]
