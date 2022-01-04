# Docker Gramine Minimal

## Overview

Minimal docker image to execute [hello.py](python/scripts/hello.py) using [Gramine](https://github.com/gramineproject/gramine) with Intel SGX.

## Build

```console
$ sudo docker build . -t gramine-minimal
```

## Run

```console
$ sudo docker run --device /dev/sgx_enclave --device /dev/sgx_provision -v /var/run/aesmd:/var/run/aesmd/ -it gramine-minimal
```

