set -euo pipefail

REPO_URL="https://github.com/davidwagnerkc/dotfiles.git"
REPO_DIR="$HOME/git/dotfiles"

mkdir -p ~/git

if [ ! -d "$REPO_DIR/.git" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
fi

if ! grep -qxF 'source ~/git/dotfiles/.bashrc' ~/.bashrc; then
  echo 'source ~/git/dotfiles/.bashrc' >> ~/.bashrc
fi

mkdir -p ~/.config/nvim
ln -sfn "$REPO_DIR/init.vim" ~/.config/nvim/init.vim
ln -sfn "$REPO_DIR/.tmux.conf" ~/.tmux.conf

sudo apt-get update
sudo apt-get -y install \
    curl \
    git \
    ripgrep \
    fzf \
    tmux \
    tree \
    zip \
    unzip \
    fd-find \
    docker.io
sudo ln -sfn "$(command -v fdfind)" /usr/local/bin/fd  # ~/.local/bin/fd
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu

curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
mkdir -p ~/.local/bin
mv nvim.appimage ~/.local/bin/nvim

wget https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz -O node.tar.xz
sudo tar -xJf node.tar.xz -C /usr/local --strip-components=1
rm node.tar.xz

curl -LsSf https://astral.sh/uv/install.sh | sh
"$HOME/.local/bin/uv" sync --project "$REPO_DIR"

if [ -f "$REPO_DIR/.venv/bin/activate" ]; then
  source "$REPO_DIR/.venv/bin/activate"
fi

nvim --headless \
  +"silent! PlugInstall --sync" \
  +"silent! PlugUpdate --sync" \
  +"silent! UpdateRemotePlugins" \
  +qa

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
