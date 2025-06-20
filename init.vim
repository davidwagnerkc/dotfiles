let vimplug_exists=expand('~/.config/nvim/autoload/plug.vim')
let g:vim_bootstrap_editor = "nvim"
if !filereadable(vimplug_exists)
  silent !\curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let g:not_finish_vimplug = "yes"
  autocmd VimEnter * PlugInstall
endif

call plug#begin(expand('~/.config/nvim/plugged'))
Plug 'joshdick/onedark.vim'                            " color scheme
Plug 'tpope/vim-fugitive'                              " git
Plug 'sheerun/vim-polyglot'                            " multi-language pack
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }    " fuzzy finder files
Plug 'psf/black'                                       " Python autoformatter
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'} " syntax highlighting
Plug 'jeetsukumaran/vim-pythonsense'                   " Python text objects
Plug 'airblade/vim-rooter'                             " pwd -> project root
Plug 'neoclide/coc.nvim', {'branch': 'release'}        " code completion + :CocInstall coc-pyright
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }
Plug 'git@github.com:github/copilot.vim.git'
call plug#end()

let g:python3_host_prog = 'python'

"" Run Black on save
"autocmd BufWritePre *.py execute ':Black'

set grepprg=rg\ --vimgrep

set termguicolors
syntax on
colorscheme onedark

"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set bomb
set binary

"" Line number
set relativenumber
set ruler
set number

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overriten by autocmd rules
set autoindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

"" Folding
"au BufNewFile,BufRead *.py \
"  | set foldmethod=indent

"" Linting
"let g:ale_linters = {'python': ['flake8']}

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

set shell=$SHELL

if has('macunix')
  " let mapleader = \<Space>"
  " pbcopy for OSX copy/paste
  vmap <C-x> :!pbcopy<CR>
  vmap <C-c> :w !pbcopy<CR><CR>
endif

" Space as map leader
let mapleader=" "
nnoremap <SPACE> <Nop>

function! GetGitRoot()
    return substitute(system("git rev-parse --show-toplevel"), '\n', '', 'g')
endfunction

" Space + p: fuzzy search files in repo
nnoremap <silent> <leader>p :execute "FZF" GetGitRoot()<cr>
nnoremap <silent> <leader>P :FZF ~<cr>

" Make Ripgrep ONLY search file contents and not filenames
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --hidden --ignore-case --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--delimiter : --nth 4.. -e'}, 'right:50%', '?'),
  \   <bang>0)

nnoremap <silent> <leader>f :Rg <cr>
nnoremap <silent> <leader>r :History: <cr>
nnoremap <silent> <leader>e :e $MYVIMRC<cr>
"" Center on search
nnoremap n nzz  
nnoremap <S-n> <S-n>zz
