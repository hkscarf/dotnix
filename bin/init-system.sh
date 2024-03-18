# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Configure System (installs `darwin-rebuild`/`home-manager` for applying future updates)
nix run nix-darwin -- switch -I --darwin=darwin.nix --flake ~/.config/dotnix

# FIXME Get default shell config working
# sudo echo /run/current-system/sw/bin/bash >> /etc/shells
# chsh -s /run/current-system/sw/bin/bash