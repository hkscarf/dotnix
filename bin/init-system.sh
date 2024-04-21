# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Nix via Determinate Systems installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Configure System (installs `darwin-rebuild`/`home-manager` for applying future updates)
nix run nix-darwin\
  --extra-experimental-features nix-command\
  --extra-experimental-features flakes\
  -- switch -I --darwin=darwin.nix --flake ~/.config/dotnix

# FIXME Get default shell config working
# sudo echo /run/current-system/sw/bin/bash >> /etc/shells
# chsh -s /run/current-system/sw/bin/bash