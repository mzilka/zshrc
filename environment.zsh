# @author       Martin Zilka
# @license    http://opensource.org/licenses/gpl-license.php
#
# original author  Sebastian Tramp <mail@sebastian.tramp.name>
# https://github.com/seebi/zshrc.git
#
# Basic environment settings related to the zsh compiliation (not private)

# XDG Base Directory Specification
# http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export ZSH_CONFIG="$XDG_CONFIG_HOME/zsh"
export ZSH_CACHE="$XDG_CACHE_HOME/zsh"
mkdir -p $ZSH_CACHE

# executable search path
export PATH=/usr/local/sbin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/sbin:$PATH
#locale
export LC_ALL=en_US.UTF-8
