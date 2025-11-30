# Use the official Ubuntu 22.04 image as a base
FROM ubuntu:22.04

# Set locale
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    openssh-client \
    jq \
    python3 \
    python3-pip \
    sshpass \
    && rm -rf /var/lib/apt/lists/*

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Set the working directory
WORKDIR /workspace

# Declare all build arguments with defaults
ARG USERNAME
ARG USER_UID
ARG USER_GID
ARG PYTHON_VERSION=3.11
ARG ANSIBLE_VERSION=9.2.0
ARG ANSIBLE_LINT_VERSION=25.1.3

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Ensure bash is the default shell for the user
RUN chsh -s /bin/bash $USERNAME

# Set ownership of workspace
RUN chown $USERNAME:$USERNAME /workspace

# Add debugging to see what values are being passed
RUN echo "Debug: ANSIBLE_VERSION='${ANSIBLE_VERSION}'" && \
    echo "Debug: ANSIBLE_LINT_VERSION='${ANSIBLE_LINT_VERSION}'" && \
    echo "Debug: USERNAME='${USERNAME}'" && \
    echo "Debug: USER_UID='${USER_UID}'" && \
    echo "Debug: USER_GID='${USER_GID}'"

# Install Ansible and related tools with specific versions
# Add validation to ensure versions are not empty or malformed
RUN if [ -z "$ANSIBLE_VERSION" ] || [ "$ANSIBLE_VERSION" = "-" ]; then \
        echo "Error: ANSIBLE_VERSION is empty or invalid: '$ANSIBLE_VERSION'"; \
        exit 1; \
    fi && \
    if [ -z "$ANSIBLE_LINT_VERSION" ] || [ "$ANSIBLE_LINT_VERSION" = "-" ]; then \
        echo "Error: ANSIBLE_LINT_VERSION is empty or invalid: '$ANSIBLE_LINT_VERSION'"; \
        exit 1; \
    fi && \
    pip3 install --no-cache-dir \
        "ansible==${ANSIBLE_VERSION}" \
        "ansible-lint==${ANSIBLE_LINT_VERSION}" \
        yamllint \
        jmespath

# Create ansible config directory and set permissions
RUN mkdir -p /etc/ansible && \
    chown -R $USERNAME:$USERNAME /etc/ansible