FROM debian:bullseye-slim

RUN apt-get update -qq && apt-get install -qq --no-install-recommends -y \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG CODE_SERVER_VERSION=4.21.1
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}

RUN mkdir -p /root/workspace /root/.config/code-server \
    && echo "bind-addr: 0.0.0.0:8080\n\
auth: password\n\
password: irull\n\
cert: false" > /root/.config/code-server/config.yaml

WORKDIR /root/workspace
EXPOSE 8080
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password", "--user-data-dir", "/root/.config/code-server"]