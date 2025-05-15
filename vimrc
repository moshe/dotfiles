" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
set encoding=utf-8

" TODO: this may not be in the correct place. It is intended to allow overriding <Leader>.
" source ~/.vimrc.before if it exists.
if filereadable(expand('~/.vimrc.before'))
  source ~/.vimrc.before
endif

" ================ General Config ====================

set backspace=indent,eol,start  "Allow backspace in insert mode
set history=5000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set guicursor=a:blinkon0        "Disable cursor blink
set visualbell                  "No sounds
set autoread                    "Reload files changed outside vim
set title
"set shortmess=atI

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" Change leader to a comma because the backslash is too far away
" That means all \x commands turn into ,x
" The mapleader has to be set before vundle starts loading all 
" the plugins.
let g:mapleader=','

" =============== Vundle Initialization ===============
" This loads all the plugins specified in ~/.vim/vundles.vim
" Use Vundle plugin to manage all other plugins
if filereadable(expand('~/.vim/vundles.vim'))
  source ~/.vim/vundles.vim
endif

" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowritebackup

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo') && !isdirectory(expand('~').'/.vim/backups')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================ Indentation ======================

set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" Auto indent pasted text
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

filetype plugin on
filetype indent on
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2
autocmd Filetype html setlocal ts=2 sts=2 sw=2


set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

" ================ Folds ============================

set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

" ================ Completion =======================

set wildmode=list:longest
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

"
" ================ Scrolling ========================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

" ================ Search ===========================

set incsearch       " Find the next match as we type the search
set hlsearch        " Highlight searches by default
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital

" ============= Personal settings ========================
imap <C-A> <C-O><Home>
imap <C-E> <C-O><End>

"Disable flush on exit
"set t_ti= t_te=


" Strip trailing whitespace
function! <SID>StripTrailingWhitespaces()
   let l:_s=@/
   let l:l = line('.')
   let l:c = col('.')
   %s/\s\+$//e
   let @/=_s
   call cursor(l:l, l:c)
endfunction

nnoremap <silent> <leader>W :call <SID>StripTrailingWhitespaces()<CR>

" Disable visual bell
set t_vb=

imap ± ~
imap § `

set wrap             " Break long lines"
set cpoptions+=$     " Show dollar sign at end of text to be changed
set lazyredraw       " Redraw only when we need to.
set relativenumber
set number

" Map z to paste and enter to insert mode
map Z :set paste<ENTER>i

" Turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>

" ================ Custom Settings ========================

so ~/.yadr/vim/settings.vim

Plugin 'johngrib/vim-game-code-break'

" ALE configurations
let g:ale_echo_msg_format = '[%linter%] %s'
let g:ale_sign_error = 'E>'
let g:ale_sign_warning = 'W>'
" highlight ALEWarning ctermbg=1
let g:ale_fix_on_save = 1
let g:ale_lint_on_save = 0
let g:ale_python_pyls_executable = '/Users/moshe/.pyenv/shims/pyls'
let g:ale_completion_enabled = 1
" set completeopt=longest,menuone
set completeopt-=menu
set completeopt+=menuone   " show the popup menu even when there is only 1 match
set completeopt-=longest   " don't insert the longest common text
" set completeopt-=preview   " don't show preview window
set completeopt+=noinsert  " don't insert any text until user chooses a match
set completeopt-=noselect  " select first match"

set dictionary+=/usr/share/dict/words " Enable the dictionary Ctrl+X Ctrl+K"

command F ALEFix
map gd :ALEGoToDefinition<CR>
map sd :ALEHover<CR>

highlight ALEError ctermbg=None cterm=underline
highlight ALEWarning ctermbg=None cterm=underline
highlight ALEStyleError ctermbg=None cterm=underline
let g:ale_fixers = {
\   'javascript': ['eslint'],
\   'python': ['autopep8', 'isort'],
\   'ruby': ['rubocop'],
\}

let g:ale_linters = {
\   'python': ['pyls'],
\}
Plugin 'w0rp/ale'

"lightline.vim
:set noshowmode

function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   l:all_non_errors,
    \   l:all_errors
    \)
endfunction

let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'ALEStatus', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'ALEStatus': 'LinterStatus'
      \ },
      \ }


"NERDTree configurations
map <C-n> :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
Plugin 'ekalinin/Dockerfile.vim'

Plugin 'kristijanhusak/vim-carbon-now-sh'
vnoremap <F5> :CarbonNowSh<CR>

"FZF
set runtimepath+=/usr/local/opt/fzf
Plugin 'junegunn/fzf.vim'
map <C-p> :GFiles<CR>
map <C-z> :History<CR>
map <C-g> :Commits<CR>
map <C-f> :Ag 

" Vim's persistent undo
set undofile                " Maintain undo history between sessions"
set undodir=~/.vim/undodir  " where to save undo histories"
set undolevels=1000         " How many undos
set undoreload=10000        " number of lines to save for undo

" Shortcuts
command Run :!clear && run.sh %<CR>
command GD :!clear && git diff
command GS :!clear && git status
command GB :!clear && git blame %
command NONU :set nonumber norelativenumber

" completer
" Plugin 'maralla/completor.vim'
" let g:completor_python_binary = '/usr/local/bin/python'
" let g:completor_node_binary = '/Users/Moshe/.nvm/versions/node/v9.2.1/bin/node'

" vim-gitgutter
Plugin 'airblade/vim-gitgutter'
:set updatetime=250
map h :GitGutterNextHunk<CR>

" Highlight tabs chargs
:highlight SpecialKey ctermfg=1
:set list
:set listchars=tab:>\ 

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
                \   '%dW %dE',
                \   l:all_non_errors,
                \   l:all_errors
                \)
endfunction
:colorscheme default

" show tabs
set list
set listchars=tab:>-

hi Folded ctermbg=19
hi Folded ctermfg=10
