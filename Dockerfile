# Gunakan image dasar
FROM ubuntu:20.04

# Set waktu dan bahasa
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y

# Install paket yang dibutuhkan
RUN apt-get install -y \
    curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf \
    tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils \
    ncdu unzip

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Siapkan direktori untuk Nexus
ENV NEXUS_HOME="/root/.nexus"
RUN mkdir -p ${NEXUS_HOME}

# Copy isi dari network-api ke dalam image
COPY . ${NEXUS_HOME}/network-api

# Set working directory
WORKDIR ${NEXUS_HOME}/network-api/clients/cli

# Jalankan aplikasi
CMD ["cargo", "run", "--release", "--bin", "prover", "--", "beta.orchestrator.nexus.xyz"]
