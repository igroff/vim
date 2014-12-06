" set up our environment for when shell out of vim
" amongst other things it sets our prompt to indicate that
" we've shelled out from vim
set shell=/bin/bash\ --rcfile\ ~/.bashvimrc

let mapleader=","

set expandtab
set tabstop=2
set shiftwidth=2

" color our 79th column so we can try and keep lines nice and short
set colorcolumn=79

" describe the way we're gonna display our interesting whitespace
set listchars=eol:$,tab:>-,trail:.,extends:>,precedes:<

" line numbers are always ncecssary, don't try and tell me otherwise
set number

" Yeah, I want cheesy poofs (syntax handling)
syntax enable

" set our colors to 256, so jellybeans will work
set t_Co=256
colorscheme jellybeans

" we'll have our guides show all the way from the left
let g:indent_guides_start_level=1

" < statusline >
set laststatus=2
set statusline=%t       "tail of the filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
" </ statusline >

" file type handling
filetype plugin on

if !exists("my_autocmds_loaded")
  augroup mine
    autocmd FileType coffee setlocal expandtab shiftwidth=2 tabstop=2
    autocmd FileType coffee let b:line_comment="#"
    autocmd FileType coffee IndentGuidesEnable

    autocmd FileType litcoffee setlocal expandtab shiftwidth=2 tabstop=2
    autocmd FileType litcoffee let b:line_comment="#"
    autocmd FileType litcoffee IndentGuidesEnable

    autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4
    autocmd FileType python let b:line_comment="#"
    autocmd FileType python IndentGuidesEnable

    autocmd BufNewFile,BufRead *.json set ft=javascript
    autocmd BufNewFile,BufRead *.conf set ft=sh
    autocmd BufNewFile,BufRead *.less set ft=css
  augroup END
  let my_autocmds_loaded=1
endif

" Insert date stamp in either normal or insert mode
nmap <leader>d ^i<C-R>=strftime("%d/%m/%Y %I:%M %z ")<CR><Esc>
imap <F3> <C-R>=strftime("%d/%m/%Y %I:%M %z ")<CR><Esc>

" I like to use minus to remove lines
map - dd

" Change our window nav so it's a bit easier
noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-h> <c-w>h
noremap <c-l> <c-w>l

" shortcut to edit vimrc
noremap <leader>ev :split $MYVIMRC<cr>
" and to source our vimrc
noremap <leader>sv :source $MYVIMRC<cr>:echo "sourced"<cr>
" wrap current word in double quotes
noremap <leader>" viw<esc>a"<esc>hbi"<esc>lel
" wrap current word in double quotes
noremap <leader>' viw<esc>a'<esc>hbi'<esc>lel

" comment all the lines in the selected region
" with the comment indicator at the begining of the line
vnoremap <leader>bc : s/^/\<C-R>=escape(b:line_comment, '\/')<CR>/<cr>
vnoremap <leader>uc : s/^\V<C-R>=escape(b:line_comment, '\/')<CR>//<cr>
" or the comment indicator before the first non whitespace character
vnoremap <leader>bbc : s/\(^\s*\)/\1\=b:line_comment/<cr>
iabbrev pythong python

function! s:ExecuteInShell(command, bang)
    let _ = a:bang != '' ? s:_ : a:command == '' ? '' : join(map(split(a:command), 'expand(v:val)'))
    if (_ != '')
    let s:_ = _
    let bufnr = bufnr('%')
    let winnr = bufwinnr('^' . _ . ')
    silent! execute	winnr < 0 ? 'new ' . fnameescape(_) : winnr . 'wincmd w'
    setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
    silent! :%d
    let message = 'Execute ' . _ . '...'
    call append(0, message)
    echo message
    silent! 2d | resize 1 | redraw
    silent! execute 'silent! %!'. _
    silent! execute 'resize ' . line(')
    silent! execute 'syntax on'
    silent! execute 'autocmd BufUnload <buffer> execute bufwinnr(' . bufnr . ') . ''wincmd w'''
    silent! execute 'autocmd BufEnter <buffer> execute ''resize '' .  line(''')'
    silent! execute 'nnoremap <silent> <buffer> <CR> :call <SID>ExecuteInShell(''' . _ . ''', '''')<CR>'
    silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . _ . ''', '''')<CR>'
    silent! execute 'nnoremap <silent> <buffer> <LocalLeader>g :execute bufwinnr(' . bufnr . ') . ''wincmd w''<CR>'
    nnoremap <silent> <buffer> <C-W>_ :execute 'resize ' . line(')<CR>
    silent! syntax on
    endif
endfunction
command! -complete=shellcmd -nargs=* -bang Shell call s:ExecuteInShell(<q-args>, '<bang>')
cabbrev shell Shell
set encoding=utf-8
let g:NERDTreeDirArrows=0
execute pathogen#infect()
