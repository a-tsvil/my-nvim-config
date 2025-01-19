Plug 'ldelossa/nvim-ide'
Plug 'dense-analysis/ale'
Plug 'bluz71/vim-nightfly-colors', { 'as': 'nightfly' }
Plug 'overcache/NeoSolarized'

" <------ Session restoration configuration ------->`
fu! SaveSess()
  execute 'mksession! ' . getcwd() . '/.session.vim'
endfunction

fu! RestoreSess()
  if filereadable(getcwd() . '/.session.vim')
    execute 'so ' . getcwd() . '/.session.vim'
    if bufexists(1)
      for l in range(1, bufnr('$'))
        if bufwinnr(l) == -1
          exec 'sbuffer ' . l
        endif
      endfor
    endif
  endif
endfunction

" <------- Auto Commands config section ------->
" autocmd VimLeave * NERDTreeClose
"autocmd VimLeave * call SaveSess()
"autocmd VimEnter * nested call RestoreSess()
"set sessionoptions-=options  " Don't save options
" autocmd VimEnter * NERDTree
" autocmd VimEnter * call timer_start(30, { tid -> execute('NERDTree')})
" autocmd VimEnter * call timer_start(170, { tid -> execute(':vertical resize +15 | :wincmd b | :belowright split terminal | :resize 10 | :wincmd b | :term ')})
" autocmd VimEnter * call timer_start(170, { tid -> execute(':vs terminal | :vertical resize 200 | :wincmd b | :term ')})

" let g:ale_go_golangci_lint_package = 1
" Prettier on save config
" autocmd BufWritePre *.ts :Prettier
" autocmd BufWritePre *.tsx :Prettier
" autocmd BufWritePre *.css :Prettier


" Use K to show documentation in preview window
" nnoremap <silent> K :call ShowDocumentation()<CR>

" function! ShowDocumentation()
"   if CocAction('hasProvider', 'hover')
"     call CocActionAsync('doHover')
"   else
"     call feedkeys('K', 'in')
"   endif
" endfunction

" <------ Temporary fix for the CoC breaking VIM's Visual Select Feature ------>
"inoremap <s-v> :CocDisable<s-v>:CocEnable
" <------ nvim-ide mappings ------>
nmap <leader>trp :Workspace RightPanelToggle<CR>
nmap <leader>cbn :Workspace Bookmarks CreateNotebook<CR>
nmap <leader>cb :Workspace Bookmarks CreateBookmark<CR>

" <------ Vim-Snip configuration ----->
" Expand
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
nmap        s   <Plug>(vsnip-select-text)
xmap        s   <Plug>(vsnip-select-text)
nmap        S   <Plug>(vsnip-cut-text)
xmap        S   <Plug>(vsnip-cut-text)

" If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']

" " <------- CoC general and autocomplete configuration ------->
" " list of CoC extension that would be automatically installed on 1st sturtup
" "      \'coc-highlight',
" let g:coc_global_extensions = [
"       \'coc-highlight',
"       \'coc-tsserver',
"       \'coc-prettier',
"       \'coc-rust-analyzer',
"       \'coc-markdownlint',
"       \'coc-explorer',
"       \'coc-json', 
"       \'coc-git',
"       \'coc-prisma',
"       \'coc-go',
"       \]

" " Use tab for trigger completion with characters ahead and navigate.
" " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" " other plugin before putting this into your config.
" inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<cr>"
" function! CheckBackspace() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~# '\s'
" endfunction
" let g:coc_snippet_next = '<tab>'
" " inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" " Insert <tab> when previous text is space, refresh completion if not.
" inoremap <silent><expr> <TAB>
"   \ coc#pum#visible() ? coc#pum#next(1):
"   \ CheckBackspace() ? "\<Tab>" :
"   \ coc#refresh()
" inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" " Use <c-space> to trigger completion.
" if has('nvim')
"   inoremap <silent><expr> <c-space> coc#refresh()
" else
"   inoremap <silent><expr> <c-@> coc#refresh()
" endif
" command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument

" " GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

" " Use K to show documentation in preview window
" nnoremap <silent> K :call ShowDocumentation()<CR>

" function! ShowDocumentation()
"   if CocAction('hasProvider', 'hover')
"     call CocActionAsync('doHover')
"   else
"     call feedkeys('K', 'in')
"   endif
" endfunction

" " Highlight the symbol and its references when holding the cursor
" autocmd CursorHold * silent call CocActionAsync('highlight')
