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
    fd-find
sudo ln -sfn "$(command -v fdfind)" /usr/local/bin/fd  # ~/.local/bin/fd


if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker ubuntu
fi

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
mkdir -p ~/.local/bin
mv nvim-linux-x86_64.appimage ~/.local/bin/nvim

wget https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz -O node.tar.xz
sudo tar -xJf node.tar.xz -C /usr/local --strip-components=1
rm node.tar.xz

curl -LsSf https://astral.sh/uv/install.sh | sh
"$HOME/.local/bin/uv" sync --project "$REPO_DIR"

if [ -f "$REPO_DIR/.venv/bin/activate" ]; then
  source "$REPO_DIR/.venv/bin/activate"
fi

"$HOME/.local/bin/nvim" --headless \
  +"silent! PlugInstall --sync" \
  +"silent! PlugUpdate --sync" \
  +"silent! UpdateRemotePlugins" \
  +qa

git config --global user.name "David Wagner"
git config --global user.email "david@wagnerkc.com"
git config --global pull.rebase false
cd ~/git/dotfiles && git remote set-url origin git@github.com:davidwagnerkc/dotfiles.git
