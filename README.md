# Mike's Dot Files Repo

This repo contains all the dotfiles for any and all projects/themes that are involved in anyway with my workflow. No PRs will be accepted. This is my trash.

Consider everything you see here to only work on Linux unless its explicitly called out otherwise

How to use

```bash
curl -fsSL https://raw.githubusercontent.com/miversen33/miversen-dotfiles/refs/heads/master/shells/zshrc | zsh
```

That script is just the zshrc I use, it can be located here: https://github.com/miversen33/miversen-dotfiles/blob/master/shells/zshrc

This script _should_ download most things you need in order to run my dotfiles. Note, it has some dependencies you might care about.
- npm (neovim language servers)
- clang/zig (neovim treesitter compilation)
- pip (neovim language servers)

Ensure that you have these 3 tools installed and on your path before you download this.

## Other shit

Along with my neovim configuration, you can find my tmux configuration in here. Don't know what tmux is? [learn yourself some tmux](https://www.man7.org/linux/man-pages/man1/tmux.1.html)

There are some other odds and ends things in here, such as my [nushell](https://www.nushell.sh) configuration, setups for both [oh-my-posh](https://ohmyposh.dev) and [oh-my-zsh](https://ohmyz.sh), my [wezterm](https://github.com/wezterm/wezterm) configuration, a powershell profile (since I have to use powershell sometimes) and other weird shit that I am probably forgetting about.

