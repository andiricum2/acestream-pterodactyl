FROM ubuntu:22.04

# Path: Dockerfile

# Set frontend to noninteractive to avoid prompts during installs
ENV DEBIAN_FRONTEND=noninteractive

# Define arguments for Acestream URL and installation directory
ARG ACESTREAM_URL="https://download.acestream.media/linux/acestream_3.2.3_ubuntu_22.04_x86_64_py3.10.tar.gz"
ARG ACESTREAM_SUBDIR="acestream" # Subdirectory within /home/container

RUN apt update && apt upgrade -y && apt install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libssl-dev \
    pkg-config \
    # --- Required for Acestream Runtime ---
    tar \
    python3 \
    libssl3 \
    ca-certificates \
    # --- End Required ---
    # Clean up APT caches
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/container container

ARG ACESTREAM_INSTALL_PATH="/home/container/${ACESTREAM_SUBDIR}"


RUN echo "Installing Acestream to ${ACESTREAM_INSTALL_PATH}..." \
    # Create the target directory
    && mkdir -p ${ACESTREAM_INSTALL_PATH} \
    # Download using the new URL
    && curl -Lf ${ACESTREAM_URL} -o /tmp/acestream.tar.gz \
    # Extract
    && tar -xzf /tmp/acestream.tar.gz -C ${ACESTREAM_INSTALL_PATH} --strip-components=1 \
    # Clean up archive
    && rm /tmp/acestream.tar.gz \
    # Ensure engine is executable
    && chmod +x ${ACESTREAM_INSTALL_PATH}/acestreamengine \
    # --- CRITICAL for Pterodactyl: Change ownership to the container user ---
    && chown -R container:container /home/container/${ACESTREAM_SUBDIR}

# --- Switch to the non-root user ---
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# Copy entrypoint and start scripts (ensure they are owned by container)
# These scripts should now only handle starting Acestream Engine
COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
COPY        --chown=container:container --chmod=755 ./start.sh /start.sh
# The line copying qbittorrent has been removed as requested

# Set the default command to run the entrypoint script
CMD         [ "/bin/bash", "/entrypoint.sh" ]