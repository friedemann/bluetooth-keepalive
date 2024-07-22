#!/bin/bash

# usage: ./bt-keepalive.sh DEVICE_MAC [LOG_FILE]
# example: ./bt-keepalive.sh "00:11:22:33:44:55" "/optional/path/to/logfile.log"

DEVICE_MAC="${1}"
LOG_FILE="${2:-"$(dirname "$0")/bt-keepalive.log"}"

if [[ -z "$DEVICE_MAC" ]]; then
  echo "Please specify a bluetooth device MAC e.g. '$0 00:11:22:33:44:55', exiting."
  exit 1
fi

for cmd in bluetoothctl pactl play; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "$cmd could not be found, please install it."
        exit 1
    fi
done

log_message() {
  local message="$1"
  echo "$(date): $message" >> "$LOG_FILE"
}

if bluetoothctl info "$DEVICE_MAC" | grep -q "Connected: yes"; then

  NORMALIZED_MAC=$(echo "$DEVICE_MAC" | tr ':' '_')
  DEVICE_STATE=$(pactl list short sinks | grep -i "bluez_output.$NORMALIZED_MAC.1" | awk '{print $NF}')

  if [[ "$DEVICE_STATE" == "SUSPENDED" ]]; then
    log_message "$(whoami) Device $DEVICE_MAC connected and $DEVICE_STATE, playing keepalive"

    # jingle [SoX man page]
    play -n synth sin %-21.5 sin %-14.5 sin %-9.5 sin %-5.5 \
      sin %-2.5 sin %2.5 gain -5.4 fade h 0.008 2 1.5 \
      delay 0 .27 .54 .76 1.01 1.3 remix - fade h 0.1 2.72 2.5 \
      gain -100 2 >/dev/null 2>&1

    # simple sine
    #play -n synth 0.5 sin 440 vol 0.5  2 >/dev/null 2>&1

    # space background [https://askubuntu.com/questions/376956/output-sox-synthesized-sound-to-file]
    #play -n -c1 synth whitenoise band -n 100 20 band -n 50 20 gain +25  fade h 1 864000 1  2 >/dev/null 2>&1

  else
    log_message "$(whoami) Device $DEVICE_MAC connected but >$DEVICE_STATE<, skipping." #Output $(pactl list short sinks)"
  fi
else
  log_message "$(whoami) Device $DEVICE_MAC is not connected, skipping"
fi