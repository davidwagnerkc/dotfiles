# TODO: Explicit check overwrite, check before append
dotfile_repo="$HOME/git/dotfiles"
files=(.condarc .gitconfig .tmux.conf)
for f in "${files[@]}"; do
    ln -sf "$dotfile_repo/$f" "$HOME/$f"
done
mkdir -p "$HOME/.config/nvim"
ln -sf "$dotfile_repo/init.vim" "$HOME/.config/nvim/init.vim"
echo '[ -r "$HOME/git/dotfiles/.bashrc.slurmy" ] && source "$HOME/git/dotfiles/.bashrc.slurmy"' >> $HOME/.bashrc
