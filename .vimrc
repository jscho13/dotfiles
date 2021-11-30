let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'itchyny/lightline.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'mileszs/ack.vim'
Plug 'pangloss/vim-javascript'
Plug 'peitalin/vim-jsx-typescript'
Plug 'leafgarland/typescript-vim'
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-abolish' " case tricks
Plug 'tpope/vim-surround' " parenthesis, quote, bracket tricks
Plug 'tpope/vim-fugitive' " git integration
Plug 'Quramy/tsuquyomi' " ts integration
Plug 'justinmk/vim-sneak'
call plug#end()

" tsuquyomi settings
let g:tsuquyomi_disable_default_mappings = 1
let g:tsuquyomi_disable_quickfix = 1
let g:syntastic_typescript_checkers = ['tsuquyomi'] " You shouldn't use 'tsc' checker.
nmap ]t :TsuquyomiDefinition<CR>
nmap ]b :TsuGeterr<CR>
nmap <Leader>s :Ack! -i -w <cword><CR>

" FZF Settings
let g:fzf_layout = { 'down':  '40%'}
let $FZF_DEFAULT_COMMAND = 'ag --ignore-dir={dist,node_modules,bin,tsBin} -g ""'
nmap <Leader>f :FZF<CR>

" Plugin specific settings
let g:netrw_liststyle = 3
let g:multi_cursor_exit_from_visual_mode = 0
let g:multi_cursor_exit_from_insert_mode = 0
let g:ackprg = 'ag --vimgrep'
let NERDTreeShowHidden=1
set laststatus=2
let g:sneak#s_next = 1

" Vim specific settings
nnoremap ; :
set belloff=all
set nu
set hlsearch
set splitright
set tabstop=2
set shiftwidth=2
set expandtab
set nopaste
set clipboard=unnamed
" color desert
colorscheme dracula

" draws a line of #
nmap ,# 72i#<ESC>
" inserts the date
nmap ,_ :silent r !date +\%F<CR>
" buffers to open for notetaking
nnoremap <Leader>1 :e ~/Dropbox/notes.txt<CR>
" Open the nerdtree
noremap <Leader>t :NERDTree<CR>
" Resize windows
noremap ,< :vertical resize -20<cr>
noremap ,> :vertical resize +20<cr>


" zo => open fold
" zc => close fold
" set foldmethod=syntax "syntax highlighting items specify folds
" set foldcolumn=1 "defines 1 col at window left, to indicate folding
" let javaScript_fold=1 "activate folding by JS syntax
" set foldlevelstart=99 "start file with all folds opened

" Home-brewed commenter and uncommenter
" :Comment and :Uncomment will comment out a given range of lines
" or visual selection.
" Comment marks will be placed at beginning of line, and only comment
" marks at the beginning of lines will be uncommented.
" Comment mark will dynamically determined to be '#', '//' or '--' depending
" on file extension of the file in buffer, and '#' if none can be detected.

func! CommentMarker()
  let ext = expand('%:e')
  if ext == 'js' || ext == 'scss' || ext == 'tsx' || ext == 'rs' || ext == 'ts'
    return '//'
  elseif ext == 'hs' || ext == 'elm' || ext == 'cabal'
    return '--'
  elseif ext == 'html'
    return '<!-- '
  else
    return '#'
  endif
endfunc
func! Comment() range
  let lnum = a:firstline
  while lnum <= a:lastline
    let line = getline(lnum)
    let newline = substitute(line, '^', CommentMarker() . ' ', '')      " comment out
    call setline(lnum, newline)
    let lnum += 1
  endwhile
endfunc
func! Uncomment() range
  let lnum = a:firstline
  while lnum <= a:lastline
    let line = getline(lnum)
    let newline = substitute(line, '^'.CommentMarker().'\s\?', '', '')   " uncomment
    call setline(lnum, newline)
    let lnum += 1
  endwhile
endfunc
command! -bar -range C :<line1>,<line2>call Comment()
command! -bar -range U :<line1>,<line2>call Uncomment()
command! -bar -range Comment :<line1>,<line2>call Comment()
command! -bar -range Uncomment :<line1>,<line2>call Uncomment()

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

function! MarkWindowSwap()
  let g:markedWinNum = winnr()
endfunction

function! DoWindowSwap()
  "Mark destination
  let curNum = winnr()
  let curBuf = bufnr( "%" )
  exe g:markedWinNum . "wincmd w"
  "Switch to source and shuffle dest->source
  let markedBuf = bufnr( "%" )
  "Hide and open so that we aren't prompted and keep history
  exe 'hide buf' curBuf
  "Switch to dest and shuffle source->dest
  exe curNum . "wincmd w"
  "Hide and open so that we aren't prompted and keep history
  exe 'hide buf' markedBuf
endfunction

"1. go to first window 2. ,mw to mark window 3. go to desired window 4. ,sm to swap window
nmap ,mw :call MarkWindowSwap()<CR>
nmap ,sw :call DoWindowSwap()<CR>

" Easily open hyperlinks in the current text buffer.
" Place cursor before or at the beginning of a URL that
" begins with http: or https: and press <leader>o

let s:http_link_pattern = 'https\?:[^ >)\]]\+'
let g:browser_command = 'open '
func! Find_href()
  let res = search(s:http_link_pattern, 'cw')
  if res != 0
    let href = matchstr(expand("<cWORD>") , s:http_link_pattern)
    return href
  end
endfunc
func! Open_href_cmd()
  return g:browser_command . " " . shellescape(Find_href()) . " "
endfunc

func! s:open_href_under_cursor()
  call system(Open_href_cmd())
endfunc

nnoremap <leader>o :call <SID>open_href_under_cursor()<CR>

func! s:open_href_under_cursor_in_buffer()
  let command = "elinks -dump -no-numbering -no-references '" . shellescape(Find_href()) . "' > elinks.buffer "
  call system(command)
  sp elinks.buffer
endfunc

nnoremap <leader>O :call <SID>open_href_under_cursor_in_buffer()<CR>

set ai et ts=2 sw=2 tw=0 exrc nocursorline hls

autocmd BufNewFile,BufRead *.txt setlocal tw=72 hls
autocmd BufNewFile,BufRead TODO setlocal tw=72 hls
autocmd BufNewFile,BufRead *.md  set ft=txt
autocmd BufNewFile,BufRead README setlocal tw=72 hls
autocmd BufNewFile,BufRead notepad*.txt setlocal tw=72 hls
autocmd BufNewFile,BufRead *.lhs set fo=tcqro
autocmd BufNewFile,BufRead *.rb set ft=ruby
autocmd BufNewFile,BufRead *.swift  set ts=4 sw=2
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

" Use gmake
" autocmd BufNewFile,BufRead Makefile*  set noet


" runs the line in Bash and appends output after the line
func! RunBashAppend()
  let cmd=getline('.')
  let res=system(getline('.'))
  normal j
  silent! put! =res
endfunc
nnoremap <leader>r :call RunBashAppend()<CR>

" prevent mistyped :w;
:cabbr w; w
