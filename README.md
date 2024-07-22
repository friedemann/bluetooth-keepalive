# bluetooth-keepalive

Small script to prevent bluetooth audio devices from shutting down when idle, my speaker's timeout is below 5 minutes (looking at you, Teufel, sry) and I always have to get up and switch it back on. Should work on debian and derivatives, haven't tested it on anything else.

## Basic Usage

1. Check out the repo, make the script executable.
1. Figure out the MAC address of the device you're aiming for via `bluetoothctl devices`
1. On the command line run it like

```bash
./bt-keepalive.sh 00:11:22:33:44:55
```

A log file is generated where the script resides. You can optionally specify a path to log the output to somewhere else (or comment the bits out).

## Run automatically

Running it once does not make a lot of sense, the easiest way is to create a cronjob for your user via `crontab -e`, e.g.

```bash
*/5 * * * * XDG_RUNTIME_DIR="/run/user/$(id -u)" /path/to/script/bt-keepalive.sh 00:11:22:33:44:55
```

The env-var is needed for the cronjob to have enough info on the pulse-audio environment, otherwise `pactl list short sinks` might fail.
