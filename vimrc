" Vundle plugins ---- {{{

set nocompatible
filetype off

if has('nvim')
    set rtp+=~/.config/nvim/bundle/Vundle.vim
else
    set rtp+=~/vim/bundle/Vundle.vim
endif

call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Plugin 'rust-lang/rust.vim.git'

Plugin 'scrooloose/nerdtree.git'

Plugin 'scrooloose/nerdcommenter.git'

Plugin 'edkolev/tmuxline.vim.git'

Plugin 'vim-airline/vim-airline.git'

Plugin 'vim-airline/vim-airline-themes.git'

Plugin 'tpope/vim-fugitive.git'

Plugin 'tpope/vim-git.git'

Plugin 'airblade/vim-gitgutter.git'

Plugin 'vimux'

Plugin 'rfc-syntax'

call vundle#end()

" }}}

" Vim settings ---- {{{

filetype plugin indent on
syntax on
syntax enable
set hidden

set wildmenu
set wildmode=list:longest
set ttyfast

set showcmd
set hlsearch
set smartcase
set backspace=indent,eol,start
set autoindent
set nostartofline
set ruler
set rulerformat=%l\:%c
set laststatus=2
set confirm
set visualbell
set t_vb=
set cmdheight=1
set number
set notimeout ttimeout ttimeoutlen=200
set pastetoggle=<F11>
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set incsearch
set scrolloff=2
set modelines=0
set encoding=utf-8
set nu

set exrc
set ff=unix
set secure
map Q gq

" }}}

" Scala Build Tool Filetype Settings ---- {{{
augroup filetype_sbt
    autocmd!
    autocmd BufNewFile,BufRead *.sbt set filetype=scala
augroup END
" }}}

" Airline Settings ---- {{{
let g:airline_theme                        = 'badwolf'
let g:airline_extensions                   = ['tmuxline', 'branch', 'tabline']
let g:airline_powerline_fonts              = 1
let g:airline#extensions#hunks#enabled     = 1
let g:airline#extensions#branch#enabled    = 1
let g:airline#extensions#tabline#enabled   = 1
let g:airline#extensions#tmuxline#enabled  = 1
" }}}

" Tmuxline Settings ---- {{{
let g:tmuxline_preset = {
      \'a'    : '#S',
      \'b'    : '#W',
      \'c'    : "#(cat /proc/loadavg | cut -d ' ' -f 1,4)",
      \'win'  : '#I #W',
      \'cwin' : '#I #W',
      \'x'    : "#(acpi -b | grep -Po '[[:digit:]]\+%')",
      \'y'    : '%a %R',
      \'z'    : '#H'}
" }}}

" Vimscript file settings ---- {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}

" Leader mapping definitions ---- {{{
let mapleader = "\\"
let maplocalleader = "-"
" }}}

" Anoying keymap settings --- {{{
" Normal Search
nnoremap / /\v
vnoremap / /\v

" Remove Up and Down
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Normal navigation (possible removal)
nnoremap j gj
nnoremap k gk

" No help key
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Remap semicolon to colon
nnoremap ; :
" }}}

" Useful keymap settings ---- {{{
" Leader remaps
nnoremap <leader>c V`]
nnoremap <leader>ev :split<cr>:e $MYVIMRC<cr>
nnoremap <leader>Ev :e $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>t :NERDTree<cr>
nnoremap <leader>cd :cd %:h<cr>
nnoremap <leader>e :tabe<space>

" Yankring
nnoremap <leader>y :YRShow<cr>

" <Esc> mods
inoremap jk <Esc>

" Usefull shortcuts
onoremap in( :<C-u>:normal! f(vi(<cr>
onoremap il( :<C-u>:normal! F)vi(<cr>
" }}}

" Window Movement Settings {{{
if has('nvim')
    set clipboard=unnamed
    tnoremap <C-h> <C-\><C-n><C-w>h
    tnoremap <C-j> <C-\><C-n><C-w>j
    tnoremap <C-k> <C-\><C-n><C-w>k
    tnoremap <C-l> <C-\><C-n><C-w>l
    tnoremap <C-n> <C-\><C-n>:tabn<cr>
    tnoremap <C-p> <C-\><C-n>:tabp<cr>
endif
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-n> :tabn<cr>
nnoremap <C-p> :tabp<cr>
nnoremap <C-e> :tabe
" }}}

" Custom Functions {{{

function! CleanUnusedBuffers()
    let all_buffers = []
    for tab in range(1, tabpagenr('$'))
        for buf in tabpagebuflist(tab)
            call add(all_buffers, buf)
        endfor
    endfor
    for buf in range(1, bufnr('$'))
        if bufexists(buf) && index(all_buffers, buf) == -1
            execute ':bdelete ' . buf
        endif
    endfor
endfunction

function! CleanLines()
    " Clean Crriage Returns
    execute ':%s/\\r\\n//g'
    " Clean Line Feeds
    execute ':%s/\\n//g'
endfunction

function! CallRFC(rfcnum)
    execute ':!rfc -q ' . a:rfcnum
    execute ':view ~/.local/share/rfcs/rfc' . a:rfcnum . '.txt'
endfunction

function! CallVRFC(rfcnum)
    execute ':!rfc -q ' . a:rfcnum
    execute ':vs|view ~/.local/share/rfcs/rfc' . a:rfcnum . '.txt'
endfunction

function! CallTRFC(rfcnum)
    execute ':!rfc -q ' . a:rfcnum
    execute ':tabe|view ~/.local/share/rfcs/rfc' . a:rfcnum . '.txt'
endfunction

nnoremap <leader>db :call CleanUnusedBuffers()<cr>
nnoremap <leader>l :call CleanCRandLF()<cr>
nnoremap <leader>x :%!xxd<cr>
nnoremap <leader>r :%!xxd -r<cr>
nnoremap <leader>n :%s/\n/\r/g<cr>
command! -nargs=1 Rfc call CallRFC(<q-args>)
command! -nargs=1 Vrfc call CallVRFC(<q-args>)
command! -nargs=1 Trfc call CallTRFC(<q-args>)
" }}}
