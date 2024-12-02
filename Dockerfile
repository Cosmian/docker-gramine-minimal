FROM ubuntu:22.04

USER root
ENV DEBIAN_FRONTEND=noninteractive
ENV TS=Etc/UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPYCACHEPREFIX=/tmp
ENV PYTHONUNBUFFERED=1

RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    pkg-config \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    gnupg \
    openssl \
    ca-certificates \
    curl \
    tzdata \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Gramine APT repository
RUN curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ jammy main" \
    | tee /etc/apt/sources.list.d/gramine.list

# Intel SGX APT repository
RUN curl -fsSLo /usr/share/keyrings/intel-sgx-deb.asc https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-sgx-deb.asc] https://download.01.org/intel-sgx/sgx_repo/ubuntu jammy main" \
    | tee /etc/apt/sources.list.d/intel-sgx.list

# Install Intel SGX dependencies and Gramine
RUN apt-get update && apt-get install -y \
    libsgx-launch \
    libsgx-urts \
    libsgx-quote-ex \
    libsgx-epid \
    libsgx-dcap-ql \
    libsgx-dcap-quote-verify \
    linux-base-sgx \
    libsgx-dcap-default-qpl \
    libsgx-aesm-quote-ex-plugin \
    gramine && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

COPY python/Makefile /root/Makefile
COPY python/python.manifest.template /root/python.manifest.template
COPY python/scripts/hello.py /root/scripts/hello.py
COPY python/scripts/args /root/scripts/args
 
RUN mkdir -p /root/.config/gramine && openssl genrsa -3 -out /root/.config/gramine/enclave-key.pem 3072
RUN make SGX=1 DEBUG=1 ENCLAVE_SIZE=4G

ENTRYPOINT ["gramine-sgx", "./python"]