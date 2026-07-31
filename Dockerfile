FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        python3 \
        software-properties-common \
        sudo \
        tzdata \
    && if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
        curl --silent --show-error --fail https://raw.githubusercontent.com/FEX-Emu/FEX/main/Scripts/InstallFEX.py | python3 || true; \
        command -v FEXBash >/dev/null 2>&1; \
       else \
        echo "Skipping FEX install on non-arm64 architecture: $(dpkg --print-architecture)"; \
       fi \
    && rm -rf /var/lib/apt/lists/*

COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/start.sh"]
