# Gunakan image dasar
FROM ubuntu:20.04

# Set waktu dan bahasa
ENV DEBIAN_FRONTEND=noninteractive

# Install paket yang dibutuhkan
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl iptables build-essential git wget lz4 jq make gcc nano \
    automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar \
    clang bsdmainutils ncdu unzip lld && \
    rm -rf /var/lib/apt/lists/*

# Install protobuf dari binary resmi
RUN curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v23.4/protoc-23.4-linux-x86_64.zip && \
    unzip protoc-23.4-linux-x86_64.zip -d /usr/local && \
    rm protoc-23.4-linux-x86_64.zip

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    rustup default nightly && rustup update && \
    rustup target add riscv32i-unknown-none-elf rust-src llvm-tools-preview

# Set PATH untuk Rust
ENV PATH="/root/.cargo/bin:/usr/local/bin:${PATH}"

# Siapkan direktori untuk Nexus
ENV NEXUS_HOME="/root/.nexus"
RUN mkdir -p ${NEXUS_HOME}

# Salin Prover ID dan network-api ke dalam image
RUN echo "Z0HcugNSokPnHg05UpxurWvC9B53" > ${NEXUS_HOME}/prover-id
COPY . ${NEXUS_HOME}/network-api

# Set working directory
WORKDIR ${NEXUS_HOME}/network-api/clients/cli

# Konfigurasi Cargo untuk target riscv32i
RUN mkdir -p ${NEXUS_HOME}/network-api/.cargo && \
    echo "[build]\ntarget = \"riscv32i-unknown-none-elf\"\nrustflags = [\"-C\", \"link-arg=-Tlink.x\"]" > ${NEXUS_HOME}/network-api/.cargo/config.toml

# Build dan jalankan aplikasi
RUN git fetch --tags && \
    git checkout $(git rev-list --tags --max-count=1) && \
    cargo clean && \
    cargo build --release -Z build-std=core,alloc --target riscv32i-unknown-none-elf --locked

# Jalankan aplikasi
CMD ["cargo", "run", "--release", "--", "--start", "--beta"]
