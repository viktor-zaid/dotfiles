# Dotfiles - CachyOS

My personal dotfiles for CachyOS with Hyprland.

## Configs

- **hypr** - Hyprland window manager
- **waybar** - Status bar
- **wlogout** - Logout menu
- **wofi** - Application launcher
- **emacs** - Text editor
- **nvim** - Neovim
- **kitty** - Terminal
- **zellij** - Terminal multiplexer

## Installation

```bash
# Clone
git clone git@github.com:Seydemann/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Symlink configs
ln -sf ~/.dotfiles/hypr ~/.config/hypr
ln -sf ~/.dotfiles/waybar ~/.config/waybar
ln -sf ~/.dotfiles/wlogout ~/.config/wlogout
ln -sf ~/.dotfiles/wofi ~/.config/wofi
ln -sf ~/.dotfiles/emacs ~/.emacs.d
ln -sf ~/.dotfiles/nvim ~/.config/nvim
ln -sf ~/.dotfiles/kitty ~/.config/kitty
ln -sf ~/.dotfiles/zellij ~/.config/zellij
```
