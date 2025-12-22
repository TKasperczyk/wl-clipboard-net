# wl-clipboard-net

Bidirectional clipboard synchronization for Wayland over network.

A lightweight solution for syncing clipboards between two Wayland machines (e.g., host and VM) where native clipboard sharing isn't available.

## Use Cases

- **VM streaming** - Sync clipboard between host and guest when using Sunshine/Moonlight, Looking Glass, or similar
- **Remote Wayland sessions** - Share clipboard between networked Wayland machines
- **Multi-machine setups** - Keep clipboards in sync across your workspace

## Requirements

- Linux with Wayland compositor (Hyprland, Sway, GNOME Wayland, etc.)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (`wl-copy`, `wl-paste`)
- netcat (`nc`) - openbsd-netcat recommended

```bash
# Arch Linux
sudo pacman -S wl-clipboard openbsd-netcat

# Debian/Ubuntu
sudo apt install wl-clipboard netcat-openbsd
```

## Installation

```bash
git clone https://github.com/TKasperczyk/wl-clipboard-net
cd wl-clipboard-net
./install.sh
```

## Configuration

Edit `~/.config/wl-clipboard-net/config`:

```bash
# Machine A (e.g., host at 192.168.122.1)
REMOTE_HOST=192.168.122.10  # Machine B's IP
SEND_PORT=9999              # Port Machine B listens on
RECV_PORT=9998              # Port this machine listens on

# Machine B (e.g., VM at 192.168.122.10)
REMOTE_HOST=192.168.122.1   # Machine A's IP
SEND_PORT=9998              # Port Machine A listens on
RECV_PORT=9999              # Port this machine listens on
```

## Usage

### As a service (recommended)

```bash
# Enable and start
systemctl --user enable --now wl-clipboard-net

# Check status
systemctl --user status wl-clipboard-net

# View logs
journalctl --user -u wl-clipboard-net -f
```

### Manual

```bash
# On host (192.168.122.1)
wl-clipboard-net -r 192.168.122.10 -s 9999 -l 9998

# On VM (192.168.122.10)
wl-clipboard-net -r 192.168.122.1 -s 9998 -l 9999
```

## Firewall

If using a firewall, allow the listening port from the remote:

```bash
# On host, allow from VM subnet
sudo iptables -I INPUT -s 192.168.122.0/24 -p tcp --dport 9998 -j ACCEPT

# On VM, allow from host
sudo iptables -I INPUT -s 192.168.122.1 -p tcp --dport 9999 -j ACCEPT
```

## How It Works

1. Each instance runs a sender and receiver loop
2. Sender polls local clipboard every 0.5s, sends changes via TCP
3. Receiver listens for incoming data, writes to local clipboard
4. MD5 hashing prevents duplicate sends

```
Machine A                          Machine B
┌─────────────────┐               ┌─────────────────┐
│ wl-clipboard-net│               │ wl-clipboard-net│
│                 │               │                 │
│ Sender ────────────TCP:9999────▶│ Receiver        │
│                 │               │                 │
│ Receiver ◀───────TCP:9998──────│ Sender          │
└─────────────────┘               └─────────────────┘
```

## Limitations

- Text only (no images or files) - but local image clipboard is preserved when text arrives
- No encryption (use on trusted networks or add SSH tunnel)
- Requires both machines running Wayland

## License

MIT
