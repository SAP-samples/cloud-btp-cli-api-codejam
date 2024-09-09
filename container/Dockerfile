# syntax=docker/dockerfile:1

FROM --platform=linux/amd64 debian:12 AS base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add Docker as source for apt
RUN apt-get update && apt-get install -y curl gpg lsb-release \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update \
 && apt-get install -y \
    ca-certificates \
    fzf \
    git \
    jq \
    nano \
    shellcheck \
    vim-nox \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/
ARG DEST=/usr/local/bin

# Install specific Node.js
ARG NODEVER=lts
RUN curl -fsSL "https://deb.nodesource.com/setup_$NODEVER.x" | bash - && apt-get install -y nodejs

# Install shfmt - shell script formatter
ARG SHFMTVER=3.4.1
RUN curl -fsSL "https://github.com/mvdan/sh/releases/download/v${SHFMTVER}/shfmt_v${SHFMTVER}_linux_amd64" -o "$DEST/shfmt" && chmod +x "$DEST/shfmt"

# Clean up temp dir
RUN rm -rf /tmp/*

# Install cf8-cli binary
RUN curl \
  --location \
  --url "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v8&source=github" \
  | tar \
    --directory /usr/local/bin \
    --gunzip \
    --extract

# Set up non-root user
ARG USERNAME=user
ARG UID=1031
RUN adduser \
  --uid $UID \
  --quiet \
  --disabled-password \
  --shell /bin/bash \
  --home /home/$USERNAME \
  --gecos "Dev User" \
  $USERNAME \
 && chown $USERNAME:$USERNAME /tmp/

USER $USERNAME
WORKDIR /home/$USERNAME
RUN mkdir /home/$USERNAME/projects
RUN echo 'export PS1="\[\e]0;\w\a\]\[\033[33;1m\]\u: \[\033[36m\]\$(basename \w) \$\[\033[m\] "' >> /home/$USERNAME/.bashrc
ENV TERM xterm-256color

CMD ["bash"]
