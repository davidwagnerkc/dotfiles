REPO="https://raw.githubusercontent.com/davidwagnerkc/dotfiles/main"

curl -s "$REPO/.bashrc" >> ~/.bashrc

mkdir -p ~/.config/nvim/
curl -s "$REPO/init.vim" -o ~/.config/nvim/init.vim

curl -s "$REPO/.tmux.conf" -o ~/.tmux.conf

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -  # for node (https://github.com/nodesource/distributions)
sudo add-apt-repository ppa:neovim-ppa/stable -y  # neovim (https://github.com/neovim/neovim/wiki/Installing-Neovim#ubuntu)
sudo apt-get update && sudo apt-get -y install \
    neovim \
    git-lfs \
    ripgrep \
    fzf \
    tmux \
    tree \
    zip \
    unzip \
    fd-find \
    nodejs
sudo ln -s $(which fdfind) /usr/local/bin/fd  # ~/.local/bin/fd

# 🐍
# curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
# chmod +x miniconda.sh
# ./miniconda.sh
# conda install conda-forge::mamba
# mamba init
# mamba env update --name dev --file env.yml

# neovim setup
# 0. Set python path in init.vim
# 1. pip install pynvim
# 2. vim (autoinstalls everything in init.vim)
# 3. :UpdateRemovePlugings

# 🐳 Docker
# Ubuntu apt-get setup https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
# docker-compose standalone https://docs.docker.com/compose/install/other/#install-compose-standalone
# permissions https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user

git config --global user.name "David Wagner"
git config --global user.email "david@wagnerkc.com"
