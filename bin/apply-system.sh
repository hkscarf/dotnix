#!/bin/sh

pushd ~/.config/dotnix
# home-manager switch --flake .#hkailahi
nix run nix-darwin\
  --extra-experimental-features nix-command\
  --extra-experimental-features flakes\
  -- switch --flake ~/.config/dotnix
popd
