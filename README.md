# Mike's Dot Files Repo

This repo contains all the dotfiles for any and all projects/themes that are involved in anyway with my workflow. No PRs will be accepted. This is my trash.

Consider everything you see here to only work on Linux unless its explicitly called out otherwise

REWRITE INCOMING!
<!
## TODO
- [ ] ~~Create Installation Script (Consider having this be part of the shellrc?)~~ **Current Target**
- [ ] Fold .p10k.sh into shellrc

### Neovim Configuration
- [Dependencies](neovim-configuration-dependencies)
- [Installation Instructions](neovim-configuration-installation)

#### Neovim Configuration Dependencies
- ctags (Recommended use of universal ctags)
- [yarn](https://classic.yarnpkg.com/en/docs/install#debian-stable)

#### Neovim Configuration Installation

The Neovim configuration can be installed by either downloading the various configuration files and placing them in their appropriate places, or cloning this repo and symlinking them
- editors/nvim/init.vim == $HOME/.config/nvim/init.vim
- editors/nvim/coc-settings.json == $HOME/.config/nvim/coc-settings.json
- editors/nvim/coc-package.json == $HOME/.config/coc/extensions/package.json

Once properly symlinked, coc will need its extensions installed
```bash
$ cd $HOME/.config/coc/extensions && yarn install
```

Finally, open up vim and run `:PlugInstall` to finish the extension setup
-->
