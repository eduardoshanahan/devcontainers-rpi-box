# Use the official Ubuntu 22.04 image as a base
FROM ubuntu:22.04

# Install basic dependencies + Ansible toolchain prerequisites
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    git-filter-repo \
    jq \
    locales \
    openssh-client \
    python3 \
    python3-pip \
    ripgrep \
    sshpass \
    wget \
    && locale-gen en_IE.UTF-8 \
    && update-locale LANG=en_IE.UTF-8 LC_ALL=en_IE.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_IE.UTF-8 \
    LANGUAGE=en_IE:en \
    LC_ALL=en_IE.UTF-8

# Install Ansible tooling via pip so the CLI and python packages stay in sync
ARG ANSIBLE_CORE_VERSION
ARG ANSIBLE_LINT_VERSION
ARG YAMLLINT_VERSION
RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir \
    "ansible-core${ANSIBLE_CORE_VERSION:+==${ANSIBLE_CORE_VERSION}}" \
    "ansible-lint${ANSIBLE_LINT_VERSION:+==${ANSIBLE_LINT_VERSION}}" \
    "yamllint${YAMLLINT_VERSION:+==${YAMLLINT_VERSION}}"

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Set the working directory
WORKDIR /workspace

ARG USERNAME
ARG USER_UID
ARG USER_GID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Ensure bash is the default shell for the user
RUN chsh -s /bin/bash $USERNAME

# Ensure prompt setup is sourced in interactive shells
RUN printf '\n# Devcontainer prompt\nif [ -f /workspace/.devcontainer/scripts/bash-prompt.sh ]; then\n  . /workspace/.devcontainer/scripts/bash-prompt.sh\nfi\n' >> /etc/bash.bashrc

# Ensure login shells also source the prompt setup
RUN printf '%s\n' '#!/bin/sh' \
    'if [ -f /workspace/.devcontainer/scripts/bash-prompt.sh ]; then' \
    '  . /workspace/.devcontainer/scripts/bash-prompt.sh' \
    'fi' \
    > /etc/profile.d/devcontainer-prompt.sh \
    && chmod 0644 /etc/profile.d/devcontainer-prompt.sh

# Set ownership of workspace
RUN chown $USERNAME:$USERNAME /workspace
