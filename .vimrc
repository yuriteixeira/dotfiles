""" GENERAL
syntax on                                   " syntax highlighting
set backspace=2                             " backspace in insert mode works like normal editor
filetype indent on                          " activates indenting for files
set autoindent                              " auto indenting
set number                                  " line numbers
set ruler                                   " show current line and column
set nobackup                                " get rid of anoying ~file
set clipboard=unnamed                       " access to system clibboard
set mouse=a                                 " mouse support
set timeout timeoutlen=5000 ttimeoutlen=100 " fix shift + o delay

""" CURSOR TWEAKS
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

""" TABS
set tabstop=4                                " the width of a TAB is set to 4.
set shiftwidth=4                             " indents will have a width of 4.
set softtabstop=4                            " sets the number of columns for a TAB.
set expandtab                                " spaces instead of tabs

""" COLORS
set background=dark
highlight LineNr ctermfg=grey ctermbg=black

""" PLUGINS
call plug#begin('~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'                    " fuzzy search
Plug 'scrooloose/nerdtree'                   " tree files navigator 
Plug 'majutsushi/tagbar'                     " ctags (symbols) mgmt panel
call plug#end()

""" PLUGINS SETTINGS

" NerdTree
map <C-n> :NERDTreeToggle<CR>

" TagBar
nmap <C-C> :TagbarToggle<CR>

