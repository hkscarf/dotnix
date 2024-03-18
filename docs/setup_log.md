# Setup Log

Rough sketch of steps


1. Install xcode cli tools

This will give you get initial `git` installation.

For example, typing `git` into terminal will prompt dialogue about installing xcode developer tools

1. Clone repo and follow configuration + installation steps

Repo at github.com/hkscarf/dotnix

3. Set default shell manually

`home-manager` and `nix-darwin` don't seem to able to.

Run something like `chsh -s /run/current-system/sw/bin/bash` after adding to `/etc/shells`

```bash
# Edit by adding /run/current-system/sw/bin/bash
sudo nano /etc/shells
# FIXME should be able to use below but getting `zsh: permission denied: /etc/shells`
# sudo echo /run/current-system/sw/bin/bash >> /etc/shells

# Set default $SHELL (unclear if possible via nix-darwin and home-manager)
chsh -s /run/current-system/sw/bin/bash
```

4. Manual installations

VPN: Mullvad
Password Manager: ???

5. Configure Git

6. Configure Whatever

7. Configure Business Apps

* Configure Google Account
  * Configure GMail account with default Mac OS Mail client
  * Configure Google Calendar account with default Mac OS Calendar client
  * etc
* Create new or connect existing Github account

BetterStack
Linear
Notion
Slack???

## Debugging Tips

* After installation, check `$PATH`
  * It should include `/run/current-system/sw/bin` and `/etc/profiles/per-user/<your-user>/bin`
