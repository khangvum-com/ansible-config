FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="manhkhang0305@gmail.com"
LABEL org.opencontainers.image.version="1.1.0"

RUN apt update

# Set NTP region
RUN DEBIAN_FRONTEND=noninteractive \
    TZ=America/Toronto \
    apt-get install tzdata -y

# Install packages
RUN apt install -y \
    ansible \
    openssh-server \
    supervisor \
    locales \
    python3 \
    python3-pip \
    sshpass

# Install pyVmomi for VMware ESXi automation
RUN pip install --break-system-packages pyvmomi

# Install required ansible-galaxy collections
# Docs:
#   - microsoft.ad: https://docs.ansible.com/ansible/latest/collections/microsoft/ad/
#   - microsoft.iis: https://docs.ansible.com/ansible/latest/collections/microsoft/iis/
RUN ansible-galaxy collection install --upgrade \
    ansible.windows \
    community.general \
    community.windows \
    microsoft.ad \
    microsoft.hyperv \
    microsoft.iis \
    khangvum.hyperv \
    community.docker \
    community.vmware

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
RUN export LC_ALL=C.UTF-8

# Create the working directory
RUN mkdir /opt/ansible
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8

# Expose port 22
EXPOSE 22

# Create sshd privilege separation
RUN mkdir /run/sshd
RUN chmod 0755 /run/sshd
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /opt/ansible

# Start the services when the server starts
CMD ["/usr/bin/supervisord"]