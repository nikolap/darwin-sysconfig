# Darwin Nix System Config

## Setup

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# or $ curl -L https://nixos.org/nix/install | sh

# I might not have needed to, but I rebooted
mkdir -p ~/.config/nix

# Emable nix-command and flakes to bootstrap 
cat <<EOF > ~/.config/nix/nix.conf
experimental-features = nix-command flakes
EOF


nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

## TODOs

- [ ] proper skuld setup
- [ ] dnsmasq
- [ ] ip script in Allianz