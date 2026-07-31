FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        software-properties-common \
        tzdata \
        xz-utils \
    && add-apt-repository -y ppa:fex-emu/fex \
    && apt-get update \
    && (apt-get install -y --no-install-recommends fex-emu-armv8.0 fex-emu-binfmt32 fex-emu-binfmt64 \
        || apt-get install -y --no-install-recommends fex-emu fex-emu-binfmt32 fex-emu-binfmt64) \
    && rm -rf /var/lib/apt/lists/*

COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/start.sh"]
