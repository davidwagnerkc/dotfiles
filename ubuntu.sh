export REPO="https://raw.githubusercontent.com/davidwagnerkc/dotfiles/main"

curl -s "$REPO/.bashrc" >> ~/.bashrc
mkdir -p ~/.config/nvim/
curl -s "$REPO/init.vim" -o ~/.config/nvim/init.vim
curl -s "$REPO/.tmux.conf" -o ~/.tmux.conf
mkdir -p ~/git

sudo apt-get update && sudo apt-get -y install \
    ripgrep \
    fzf \
    tmux \
    tree \
    zip \
    unzip \
    fd-find
sudo ln -s $(which fdfind) /usr/local/bin/fd  # ~/.local/bin/fd

curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
mkdir -p ~/.local/bin
mv nvim.appimage ~/.local/bin/nvim

wget https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz -O node.tar.xz
sudo tar -xJf node.tar.xz -C /usr/local --strip-components=1
rm node.tar.xz

# neovim setup
# 1. pip install pynvim
# 2. vim (autoinstalls everything in init.vim)
# 3. :UpdateRemotePlugings

# jupyter
# pip install jupyterlab jupyterlab-vim ipdb
# https://github.com/johnnybarrels/jupyterlab_onedarkpro/pull/14#issuecomment-1906559911

git config --global user.name "David Wagner"
git config --global user.email "david@wagnerkc.com"
git config --global pull.rebase false
