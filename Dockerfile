FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install --no-install-recommends -y \
    wget \
    curl \
    git \
    vim \
    sudo \
    tzdata \
    net-tools \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG CODE_SERVER_VERSION=4.21.1
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}

RUN mkdir -p /root/workspace

RUN mkdir -p /root/.config/code-server

RUN echo "bind-addr: 0.0.0.0:8080\n\
auth: password\n\
password: vscode\n\
cert: false" > /root/.config/code-server/config.yaml

RUN code-server --install-extension ms-python.python \
    && code-server --install-extension ms-azuretools.vscode-docker \
    && code-server --install-extension dbaeumer.vscode-eslint \
    && code-server --install-extension esbenp.prettier-vscode

WORKDIR /root/workspace

EXPOSE 8080

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password", "--user-data-dir", "/root/.config/code-server"]