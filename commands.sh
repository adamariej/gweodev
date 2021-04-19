#/bin/bash

export GWEODEV="`readlink -e $(dirname $0)`"

pm="apt"
graphics="yes"

if test -e ~/.gitconfig -o \
	-e ~/.vimrc -o \
	-e ~/.gitignore -o \
	-e ~/.zsh_cusom -o \
	-e ~/.gweodev_local -o \
	-e ~/.tmux.conf; then
	printf "Already deployed installation. Abort\n"
	exit 1
fi

# install tools
sudo $pm install -y vim git gdb tmux tig htop nano zsh wget curl python3 python3-pip

# create symlinks
if test ! -d ~/.zsh_custom; then
	ln -sf $GWEODEV/gweodenv/zsh/custom ~/.zsh_custom
fi

# create HOME links to default config files
ln -sf $GWEODEV/gweodenv/zsh/zshrc ~/.zshrc
ln -sf $GWEODEV/git/gitconfig ~/.gitconfig
ln -sf $GWEODEV/git/gitattributes ~/.gitattributes
ln -sf $GWEODEV/git/gitignore ~/.gitignore
ln -sf $GWEODEV/tmux/tmux.conf ~/.tmux.conf
ln -sf $GWEODEV/gdb/gdbinit ~/.gdbinit
ln -sf $GWEODEV/vim/vimrc ~/.vimrc

# deploy VIM plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/vundle.vim
vim +PluginInstall +qall
~/.vim/bundle/fonts/install.sh

# GUI ? enable i3
if test "x$graphics" = "xyes"; then
	$pm install -y i3 i3status rofi i3lock i3pystatus
	test -d ~/.config/i3 && mkdir -p ~/.config/i3
	test -d ~/.config/rofi && mkdir -p ~/.config/rofi
	ln -sf $GWEODEV/resources/i3/config ~/.config/i3/config
	ln -sf $GWEODEV/resources/i3bar/statusbar.py ~/.config/i3/statusbar.py
	ln -sf $GWEODEV/resources/rofi/config ~/.config/rofi/config
fi

# install oh-my-zsh, requires interaction
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# configure virtualenvwrapper
pip3 install --user virtualenvwrapper virtualenv

# complete with alacritty installation
#wget https://github.com/alacritty/alacritty/archive/refs/tags/v0.7.2.tar.gz
#tar xf v0.7.2.tar.gz

# diff-so-fancy
#curl -sSL https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/diff-so-fancy -o ~/.usr/bin/diff-so-fancy
#chmod +x ~/.usr/bin/diff-so-fancy

# discord
curl -sSL https://discord.com/api/download?platform=linux&format=deb -o discord.deb
sudo $pm install ./discord.deb -y

# spotify
#curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
#echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
#sudo $pm update
#sudo $pm install spotify-client

# VS Code
curl -sSL https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb
sudo apt install ./vscode.deb -y

cat<<EOF > ~/.gweodev_local
PATH=$HOME/.usr/bin:$PATH; export PATH
LD_LIBRARY_PATH=$HOME/.usr/lib:$HOME/.usr/lib64:$LD_LIBRARY_PATH; export LD_LIBRARY_PATH
INCLUDE_PATH=$HOME/.usr/include:$INCLUDE_PATH; export INCLUDE_PATH
MANPATH=$HOME/.usr/man:$MANPATH; export MANPATH

WORKON_HOME=$HOME/.virtualenvs; export WORKON_HOME
VIRTUALENVWRAPPER_PYTHON=$(which python3)
VIRTUALENVWRAPPER_VIRTUALENV=~/.local/bin/virtualenv
source ~/.local/bin/virtualenvwrapper.sh
EOF


