""" GENERAL
syntax on                                   " syntax highlighting
filetype indent on                          " activates indenting for files
set backspace=2                             " backspace in insert mode works like normal editor
set autoindent                              " auto indenting
set number                                  " line numbers
set ruler                                   " show current line and column
set nobackup                                " get rid of anoying ~file
set noswapfile                              " no swap files
set clipboard=unnamed                       " access to system clibboard
set mouse=a                                 " mouse support
set timeout timeoutlen=5000 ttimeoutlen=100 " fix shift + o delay
let mapleader=","                           " maps leader to comma

""" CURSOR TWEAKS
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

""" TABS
set tabstop=4                                " the width of a TAB is set to 4.
set shiftwidth=4                             " indents will have a width of 4.
set softtabstop=4                            " sets the number of columns for a TAB.
set expandtab                                " spaces instead of tabs

nnoremap L gt
nnoremap H gT
nnoremap Q :tablast<CR>

""" SPLITS
set splitbelow
set splitright

" Movements
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

""" TOGGLES

" Relative numbers
nnoremap <C-R>1 :set relativenumber<CR>
nnoremap <C-R>0 :set norelativenumber<CR>

" Auto-indent
nnoremap <C-I>1 :set autoindent<CR>
nnoremap <C-I>0 :set noautoindent<CR>

""" AUTOMATION

" Auto-reload .vimrc
autocmd! bufwritepost .vimrc source %



""" PLUGINS
call plug#begin('~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'                    " File search
Plug 'chriskempson/base16-vim'               " Base 16 Colorscheme
Plug 'scrooloose/nerdtree'                   " File navigator 
Plug 'majutsushi/tagbar'                     " Symbols navigator
Plug 'mxw/vim-jsx'                           " JSX syntax support
Plug 'pangloss/vim-javascript'               " JS syntax support
Plug 'qbbr/vim-twig'                         " Twig support
Plug 'editorconfig/editorconfig-vim'         " Editor config (http://editorconfig.org/)
Plug '907th/vim-auto-save'                   " Auto-save files
Plug 'jiangmiao/auto-pairs'                  " Auto-close brackets
Plug 'mileszs/ack.vim'                       " Text Search
Plug 'mattn/emmet-vim'                       " Emmet (formerly Zencoding)
Plug 'bling/vim-airline'                     " Status line (powerline like)
Plug 'vim-airline/vim-airline-themes'        " Status line color themes
Plug 'airblade/vim-gitgutter'                " Git: show changes on editor
Plug 'scrooloose/nerdcommenter'              " Comments
Plug 'honza/vim-snippets'                    " Snippets
Plug 'tpope/vim-fugitive'                    " Git plugin
call plug#end()

" NerdTree
nnoremap <C-N> :NERDTreeToggle<CR>
let g:NERDTreeWinSize=40 
let NERDTreeShowHidden=1

" TagBar 
nnoremap <C-C> :TagbarToggle<CR>

" JSX
let g:jsx_ext_required=0

" CTRL+P
nnoremap <C-O> :CtrlPBuffer<CR>

let g:ctrlp_match_window_bottom=1
let g:ctrlp_working_path_mode=0
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40
let g:ctrlp_user_command=['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" The silver seacher
if executable('ag')
    " Let CtrlP use ag as backend
    let g:ctrlp_user_command='ag %s -l --nocolor -g ""'
    let g:ctrlp_use_caching=0

    " Let Ack.vim use Ag as backend
    let g:ackprg = 'ag --nogroup --nocolor --column'
endif

" Auto-save
let g:auto_save=0

" Ack.vim
cnoreabbrev Ack Ack!
nnoremap <C-A> :Ack!<Space>

" Emmet
let g:user_emmet_leader_key='<C-X>'

" Airline
let g:airline_left_sep=''
let g:airline_right_sep=''
set laststatus=2
set ttimeoutlen=50

" Colors
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
