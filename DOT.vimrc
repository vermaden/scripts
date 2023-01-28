" -- < GENERAL >-- "
set nomodeline
set nocompatible
set backspace=indent,eol,start
set autoindent
set expandtab 
set nobackup
set number
set nowrap
set history=32
set ignorecase
set showcmd
set incsearch
set hlsearch
set tabstop=8
set shiftwidth=8
set softtabstop=8
set noexpandtab
set ruler
set mouse-=a

" disable ~/.viminfo file
let skip_defaults_vim=1
set viminfo=""

" set virtualedit=all
" ALLOWS TO MOVE CURSOR PAST LAST CHARACTER

" --< COMMANDS >-- "
command WQ wq
command Wq wq
command W  w
command Q  q

" --< COLORS / SYNTAX >-- "
syntax on
" colorscheme solarized

" --< TABS BINDINGS >-- "
" map <C-t>     :tabnew<CR>
" map <C-w>     :tabclose<CR>
" map <C-left>  :tabp<CR>
" map <C-right> :tabn<CR>
" map <C-home>  :tabfirst<CR>
" map <C-end>   :tablast<CR>

" --< TEMP >-- "
" map q ^Y				-- 'q' is scroll line up
" map z ^E				-- 'z' is scroll line down
" map ; ^B				-- ';' page up
" map , ^F				-- ',' page down
