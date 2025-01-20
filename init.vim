" nvim/neovide configuration created and maintained by DioDredd
" plugins list
call plug#begin('~/.nvim/plugin')
    Plug 'scrooloose/nerdtree'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'nvim-lualine/lualine.nvim'

    " If you want to have icons in your statusline choose one of these
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'ryanoasis/vim-devicons'

    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip'

    Plug 'neovim/nvim-lspconfig'
    Plug 'ray-x/lsp_signature.nvim'

    Plug 'airblade/vim-gitgutter'
    Plug 'folke/todo-comments.nvim'

    " Colorschemes plugins
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'morhetz/gruvbox'
    Plug 'EdenEast/nightfox.nvim'
    Plug 'arcticicestudio/nord-vim'
    Plug 'rose-pine/neovim'
    Plug 'catppuccin/nvim'

    Plug 'chrisbra/Colorizer'
    " Plug 'wellle/context.vim'
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}

    " Mr TPOPE
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-fugitive'

    " Language-specific
    Plug 'rust-lang/rust.vim'
    Plug 'hashivim/vim-terraform'
    Plug 'prisma/vim-prisma'
    Plug 'ray-x/go.nvim'
    Plug 'ray-x/guihua.lua'
    " Plug 'gleam-lang/gleam.vim'

    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'sbdchd/neoformat'
    Plug 'folke/trouble.nvim'
    Plug 'dgagn/diagflow.nvim'
    Plug 'stevearc/aerial.nvim'
    Plug 'rafamadriz/friendly-snippets'
 
    " Plug 'williamboman/mason.nvim'
call plug#end()

"<------- General configuraiton ------->
set number
set relativenumber
set clipboard+=unnamedplus
set nowrap
set showmatch
set ignorecase
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=2
set cursorline
set list
" lead:⋅
set listchars=tab:›\ ,trail:⋅
set conceallevel=2

" Color scheme settings
colorscheme tokyonight-night
let g:nord_contrast = v:false
let g:nord_borders = v:true
let g:nord_disable_background = v:false
let g:nord_italic = v:false
let g:nord_uniform_diff_background = v:true
let g:nord_bold = v:false
let g:nord_cursorline_transparent = v:true

let g:colorizer_auto_filetype='css,html,js,ts,svelte'

" <------ Neovide config section ------>
if exists("g:neovide")
    set guifont=Iosevka\ Curly:h15.5
    " set guifont=Victor\ Mono:h13.5
    "let g:transparency = 0.9
    let g:neovide_scroll_animation_length = 0.55
    let g:neovide_transparency = 0.92
    let g:neovide_remember_window_size = v:true
    let g:neovide_refresh_rate = 2000
    let g:neovide_cursor_vfx_mode = 'sonicboom'
endif

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" File History open mapping
nmap <silent> <leader>m :History<CR>

" <------ NERDTree configuration ------>
let NERDTreeShowHidden=1
map <leader>r :NERDTreeFind<cr>
nnoremap <leader>nf :NERDTreeFind<CR>

" <------ MacOS-specific settings section ------->
"let g:coc_node_path = '/home/difodredd/.nvm/versions/node/v18.15.0/bin/node'
"let g:coc_node_path = trim(system('which node'))

map rf :%! rustfmt <CR>

" <------ Commentary.vim ------>
filetype plugin indent on
map gc :Commentary <CR>
map gcc :Commentary <CR>

" <------ Ctrl-P configuration ------>
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" <------ Neoformat configuration --->
let g:neoformat_try_node_exe = 1
nnoremap <leader>fm :Neoformat<CR>

" <------ Semantic highlighting on hold --->
autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()

" <------ Lua configurations import  ------>
:source 'lua/config.lua'

