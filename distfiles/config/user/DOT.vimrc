"GENERAL"
set nomodeline
set nocompatible
set backspace=indent,eol,start
set autoindent
set nobackup
set number
set nowrap
set history=32
set ignorecase
set showcmd
set incsearch
set hlsearch
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set ruler
set mouse-=a

"DISABLE ~/.viminfo FILE"
let skip_defaults_vim=1
set viminfo=""

"ALLOW MOVE CURSOR PAST LAST CHARACTER"
set virtualedit=all

"COMMANDS"
command WQ wq
command Wq wq
command W  w
command Q  q

"COLORS/SYNTAX"
syntax on
