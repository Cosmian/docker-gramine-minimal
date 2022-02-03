FROM ubuntu:focal

USER root
ENV DEBIAN_FRONTEND=noninteractive
ENV TS=Etc/UTC
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /root

RUN apt-get update && apt-get install --no-install-recommends -qq -y \
  wget \
  unzip \
  protobuf-compiler \
  libprotobuf-dev \
  libprotobuf-c-dev \
  build-essential \
  cmake \
  pkg-config \
  gdb \
  python3 \
  git \
  gnupg \
  ca-certificates \
  curl \
  tzdata \
  && apt-get -y -q upgrade \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ stable main" >> /etc/apt/sources.list.d/gramine.list \
  && curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg 

RUN echo "deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" >> /etc/apt/sources.list.d/intel-sgx.list \
  && wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add -

RUN apt-get update && apt-get install --no-install-recommends -qq -y \
  gramine \
  libsgx-launch \
  libsgx-urts \
  libsgx-quote-ex \
  libsgx-epid \
  libsgx-dcap-ql \
  libsgx-dcap-default-qpl \
  sgx-aesm-service \
  libsgx-aesm-quote-ex-plugin \
  && rm -rf /var/lib/apt/lists/*

# SGX SDK is installed in /opt/intel directory.
WORKDIR /opt/intel

ARG SGX_SDK_INSTALLER=sgx_linux_x64_sdk_2.15.101.1.bin

# Install SGX SDK
RUN wget https://download.01.org/intel-sgx/sgx-linux/2.15.1/distro/ubuntu20.04-server/$SGX_SDK_INSTALLER \
  && chmod +x  $SGX_SDK_INSTALLER \
  && echo "yes" | ./$SGX_SDK_INSTALLER \
  && rm $SGX_SDK_INSTALLER

WORKDIR /root

COPY python/Makefile python/python.manifest.template python/enclave-test-key.pem /root/
COPY python/scripts/hello.py /root/scripts/hello.py

RUN make SGX=1 DEBUG=1

ENTRYPOINT ["gramine-sgx", "./python", "scripts/hello.py"]
