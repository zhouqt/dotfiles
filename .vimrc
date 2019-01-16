" Copied from the default vimrc file, 2017 Jun 13 version.
" vim: ft=vim foldmethod=marker

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
" Avoid side effects when it was already reset.
if &compatible
  set nocompatible
endif

" When the +eval feature is missing, the set command above will be skipped.
" Use a trick to reset compatible only when the +eval feature is missing.
silent! while 0
  set nocompatible
silent! endwhile

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

"set encoding=cp936
set fileencodings=utf-8,gbk,gb2312,gb18030,ucs-bom,latin1
"set fileencoding=utf-8          " character encoding for file of the buffer


set history=200		" keep 200 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set statusline=%<%h%m%r\ %f%=[%{&filetype},%{&fileencoding},%{&fileformat}]%k\ %-14.(%l/%L,%c%V%)\ %P
"set wildmenu		" display completion matches in a status line
set wildmode=longest:list,full
"set cmdheight=2
"set notitle             " do not set xterm dynamic title
set number          "show line number

set matchtime=5
set lazyredraw          " faster for macros
set ttyfast             " better for xterm

set ttimeout		" time out for key codes
set ttimeoutlen=100	" wait up to 100ms after Esc for special key

" Show @@@ in the last line if it is truncated.
set display=truncate

set hidden              " hide instead of abandon buffer
set wrap
set whichwrap=b,s,<,>,h,l
set laststatus=2    "show status line
set foldenable
set foldmethod=marker   " fdm=syntax is very slow and makes trouble for neocomplete

" Show a few lines of context around the cursor.  Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5
set smartindent autoindent
" replace <tab> with 2 blank space.
set expandtab smarttab shiftwidth=4 softtabstop=4 tabstop=4
set textwidth=80	" wrap text for 78 letters
" set relativenumber

set magic

if executable( 'par' )
    set formatprg=par\ req
else
    set formatprg=fmt
endif
set formatoptions+=mM     " default tcq, mM to help wrap chinese

set backup
if !isdirectory($HOME . "/.vim/backup")
    call mkdir($HOME . "/.vim/backup", "p")
endif
set backupdir=$HOME/.vim/backup
set directory=$HOME/.vim/backup     "swp

" A hack so that vim does not break docker bind-mount
"https://github.com/moby/moby/issues/15793
set backupcopy=yes

if !isdirectory($HOME . "/.vim/undo")
    call mkdir($HOME . "/.vim/undo", "p")
endif
set undodir=~/.vim/undo undofile undolevels=1000 undoreload=1000

set commentstring=#%s       " default comment style
set sps=best,10             " only show 10 best spell suggestions
set dictionary+=/usr/share/dict/words

" make fuzzy find in :find command possible
set path+=**

" disable bell all together
set noeb vb t_vb=

set showmatch          " show the matching brackets when typing
" set ambiwidth=double     " set this if terminal has similar setting

" Do incremental searching when it's possible to timeout.
if has('reltime')
  set incsearch hlsearch wrapscan
  set ignorecase smartcase
endif

" Do not recognize octal numbers for Ctrl-A and Ctrl-X, most users find it
" confusing.
set nrformats-=octal

" make spell suggest faster
set spellsuggest=best
set spelllang=en_gb,cjk

" Don't use Ex mode, use Q for formatting.
" Revert with ":unmap Q".
map Q gq

" In many terminal emulators the mouse works just fine.  By enabling it you
" can position the cursor, Visually select and scroll with the mouse.
"if has('mouse')
"  set mouse=a
"endif

" Switch syntax highlighting on when the terminal has colors or when using the
" GUI (which always has colors).
if &t_Co > 2 || has("gui_running")
  " Revert with ":syntax off".
  color elflord
  syntax on

  "if v:version > 800
  "  set termguicolors
  "endif

  " I like highlighting strings inside C comments.
  " Revert with ":unlet c_comment_strings".
  let c_comment_strings=1

  set guioptions-=T
  set guioptions-=r
  " For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries.
  if has('win32')
    set guioptions-=t
  endif

  let s:uname = system("uname")
  if s:uname == "Darwin\n"
      "Mac options here
      set guifont=Ubuntu\ Mono:h13
  else
      set guifont=Monaco\ 10
      set guifontwide=WenQuanYi\ Micro\ Hei\ 12
  endif

  if has("gui_macvim")
      let macvim_skip_colorscheme=1
      color desert
  endif

endif

set autoindent        " always set autoindenting on
set smartindent

"---------------------encoding detection--------------------------------
set fileencoding&
set fileencodings=ucs-bom,utf-8,enc-cn,cp936,gbk,latin1

"---------------------completion settings-------------------------------
"make completion menu usable even when some characters are typed.
set completeopt=longest,menuone
" set complete-=i
" set complete-=t
set complete+=kspell

" Key mapping {{{
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-U>".
inoremap <C-U> <C-G>u<C-U>

imap <C-F10> <!--
imap <C-F11>  -->

" search for visual-mode selected text
vmap / y/<C-R>"<CR>
" }}}

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
" Revert with ":filetype off".
filetype plugin indent on
set autochdir

" Put these in an autocmd group, so that you can revert them with:
" ":augroup vimStartup | au! | augroup END"
augroup vimStartup
au!
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid, when inside an event handler
" (happens when dropping a file on gvim) and for a commit message (it's
" likely a different one than last time).
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

augroup END


"--------------------------file type settings---------------------------
"{{{
" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

"Python
"autocmd FileType python setlocal makeprg="python -u %"
autocmd FileType python set omnifunc=pythoncomplete#Complete

"Ruby
"no folding for comment block and if/do blocks
let ruby_no_comment_fold=1
let ruby_fold=1
let ruby_operators=1
autocmd FileType ruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby let g:rubycomplete_classes_in_global = 1
autocmd BufRead,BufNewfile Vagrantfile set ft=ruby

"emails,
"delete old quotations, set spell and put cursor in the first line
autocmd FileType mail
            \|:silent setlocal fo+=aw       " http://wcm1.web.rice.edu/mutt-tips.html
            \|:silent set spell
            "\|:silent 0put=''
            \|:silent g/^.*>\sOn.*wrote:\s*$\|^>\s*>.*$/de
            \|:silent 1

"markdown
autocmd BufNewFile,BufRead *mkd,*.md,*.mdown set ft=markdown
autocmd FileType markdown set comments=n:> nu nospell textwidth=0 formatoptions=tcroqn2

"remind
autocmd BufNewFile,BufRead *.rem set ft=remind

"crontab hack for mac
autocmd BufEnter /private/tmp/crontab.* setl backupcopy=yes

"Auomatically add file head defined in ~/.vim/templates/
au BufNewFile * silent! exec ":0r " . g:vim_home . "/templates/" . &ft | normal G
" }}}

"-------------------special settings------------------------------------
" {{{ big files?
let g:LargeFile = 0.3	"in megabyte
augroup LargeFile
    au!
    au BufReadPre *
        \let f=expand("<afile>")
        \|if getfsize(f) >= g:LargeFile*1023*1024 || getfsize(f) <= -2
            \|let b:eikeep = &ei
            \|let b:ulkeep = &ul
            \|let b:bhkeep = &bh
            \|let b:fdmkeep= &fdm
            \|let b:swfkeep= &swf
            \|set ei=FileType
            \|setlocal noswf bh=unload fdm=manual
            \|let f=escape(substitute(f,'\','/','g'),' ')
            \|exe "au LargeFile BufEnter ".f." set ul=-1"
            \|exe "au LargeFile BufLeave ".f." let &ul=".b:ulkeep."|set ei=".b:eikeep
            \|exe "au LargeFile BufUnload ".f." au! LargeFile * ". f
            \|echomsg "***note*** handling a large file"
        \|endif
    au BufReadPost *
        \if &ch < 2 && getfsize(expand("<afile>")) >= g:LargeFile*1024*1024
            \|echomsg "***note*** handling a large file"
        \|endif
augroup END
" }}}

" {{{ restore views
set viewoptions=cursor,folds,slash,unix
augroup vimrc
    autocmd BufWritePost *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      mkview!
    \|  endif
    autocmd BufRead *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      silent! loadview
    \|  endif
augroup END
" }}}

" Highlight keywords like TODO BUG HACK INFO and etc {{{ "
autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|XXX\|BUG\|HACK\)')
autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\)')
" }}} Highlight keywords like TODO BUG HACK INFO and etc "

" {{{ Changing cursor shape per mode
" NOTE does not work over ssh
" 1 or 0 -> blinking block
" 2 -> solid block
" 3 -> blinking underscore
" 4 -> solid underscore
" 5 -> blinking bar (xterm)
" 6 -> steady bar (xterm)
if exists('$TMUX')
    " tmux will only forward escape sequences to the terminal if surrounded by a DCS sequence
    let &t_SI .= "\<Esc>Ptmux;\<Esc>\<Esc>[5 q\<Esc>\\"
    let &t_SR .= "\<Esc>Ptmux;\<Esc>\<Esc>[4 q\<Esc>\\"
    let &t_EI .= "\<Esc>Ptmux;\<Esc>\<Esc>[2 q\<Esc>\\"
    autocmd VimLeave * silent !echo -ne "\033Ptmux;\033\033[2 q\033\\"
else
    let &t_SI .= "\<Esc>[5 q"
    let &t_SR .= "\<Esc>[4 q"
    let &t_EI .= "\<Esc>[2 q"
    autocmd VimLeave * silent !echo -ne "\033[2 q"
endif
" }}}

" visual p does not replace paste buffer {{{ "
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()
" }}} visual p does not replace paste buffer "


" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" langmap {{{
if has('langmap') && exists('+langremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If set (default), this may break plugins (but it's backward
  " compatible).
  set nolangremap
endif "}}}

" for pydiction {{{
let g:pydiction_location = '~/.vim/ftplugin/complete-dict'
" }}}

" for taglist {{{
set tags=tags;

let Tlist_Show_One_File = 1            "不同时显示多个文件的tag，只显示当前文件的
let Tlist_Exit_OnlyWindow = 1          "如果taglist窗口是最后一个窗口，则退出vim
let Tlist_Use_Right_Window = 1         "在右侧窗口中显示taglist窗口
nmap tl :TlistToggle<CR>
" }}}

" for cscpoe {{{
" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim...
if has("cscope")

    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag
    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0
    " add any cscope database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
    endif
    if filereadable("../cscope.out")
        cs add ../cscope.out
    " else add the database pointed to by environment variable
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    " show msg when any other cscope db added
    set cscopeverbose

    "是否使用 quickfix 窗口来显示 cscope 结果
    set cscopequickfix=s-,c-,d-,g-,i-,t-,e-

    " The following maps all invoke one of the following cscope search types:
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
endif " }}}

if filereadable( $HOME . '/.vimrc.plug' )
    source $HOME/.vimrc.plug
endif
