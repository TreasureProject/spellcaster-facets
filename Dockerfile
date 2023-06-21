FROM node:18.12.1-slim
ARG ARCH=arm64
USER 0
RUN apt-get update
# RUN apt-get install --yes wget git curl unzip xz-utils nodejs npm
RUN apt-get install --yes git curl unzip gcc

# Rustup
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y

# Add .cargo/bin to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Install foundry to skip that setup step
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/root/.foundry/bin:${PATH}"
RUN foundryup