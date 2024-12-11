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

# Salin Prover ID dan network-api ke dalam image
RUN echo "Z0HcugNSokPnHg05UpxurWvC9B53" > ${NEXUS_HOME}/prover-id
COPY . ${NEXUS_HOME}/network-api

# Set working directory
WORKDIR ${NEXUS_HOME}/network-api/clients/cli

# Build dan jalankan aplikasi
RUN git stash save && git fetch --tags
RUN git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1)
RUN cargo build --release

# Jalankan aplikasi
CMD ["cargo", "run", "--release", "--bin", "prover", "--", "beta.orchestrator.nexus.xyz"]
