#!/bin/bash

# Set the Pterodactyl HOME variable if it's not already set (good practice)
# Pterodactyl should set $HOME, but this provides a fallback.
INTERNAL_HOME=${HOME:=/home/container}

# Path to the Acestream Engine executable within the user's home directory
ACESTREAM_ENGINE_PATH="$INTERNAL_HOME/acestream/acestreamengine"

# --- Configuration Flags for Acestream Engine ---
# --bind-host 0.0.0.0 : REQUIRED inside Docker to listen on all container interfaces,
#                       allowing connections from the host or other containers.
# --client-console    : Run in headless mode without a GUI.
# --service-port PORT : Optional: Change the default service port (default: 6878). Example: --service-port 6878
# --cache-dir PATH    : Optional: Specify where cache files go. Defaults likely within $HOME/.ACEStream
#                       Example: --cache-dir "$INTERNAL_HOME/.cache/acestream"
# --service-remote-access : Optional: Allow remote connections to the engine's API/service port.
#                           Needed if something outside the container needs to talk to it.
# --log-level debug/info/warning/error : Optional: Set logging verbosity.
#
# Add or modify flags as needed for your specific use case.
ACESTREAM_FLAGS="--bind-host 0.0.0.0 --client-console"
# Example with more flags:
# ACESTREAM_FLAGS="--bind-host 0.0.0.0 --client-console --service-remote-access --log-level info"

# --- Script Execution ---

# Clear the screen (optional, for cleaner logs in Pterodactyl console)
# clear

echo "============================================================"
echo " Initializing Acestream Engine Startup Script"
echo " User:         $(whoami)"
echo " Home Dir:     $INTERNAL_HOME"
echo " Engine Path:  $ACESTREAM_ENGINE_PATH"
echo " Flags:        $ACESTREAM_FLAGS"
echo "============================================================"

# Check if the engine executable exists
if [ ! -f "${ACESTREAM_ENGINE_PATH}" ]; then
    echo "[ERROR] Acestream engine executable not found!"
    echo "[ERROR] Expected at: ${ACESTREAM_ENGINE_PATH}"
    echo "[ERROR] Please ensure the Dockerfile installed it correctly and the path is right."
    exit 1 # Exit immediately if the engine isn't found
fi

# Check if the engine is executable
if [ ! -x "${ACESTREAM_ENGINE_PATH}" ]; then
    echo "[ERROR] Acestream engine is not executable!"
    echo "[ERROR] Path: ${ACESTREAM_ENGINE_PATH}"
    echo "[ERROR] Check permissions in the Dockerfile (chmod +x)."
    exit 1 # Exit immediately
fi

echo "---> Launching Acestream Engine..."

# Use 'exec' to replace the current shell process with the Acestream Engine process.
# This is important for Pterodactyl, as it will directly monitor the engine's PID.
# When the engine stops, the container stops.
exec ${ACESTREAM_ENGINE_PATH} ${ACESTREAM_FLAGS}

# If exec fails for some reason (e.g., engine crashes immediately), this line might be reached.
echo "[ERROR] Failed to execute Acestream Engine!"
exit 1