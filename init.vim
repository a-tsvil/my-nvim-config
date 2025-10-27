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
    Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip'

    Plug 'neovim/nvim-lspconfig'
    Plug 'ray-x/lsp_signature.nvim'

    " Plug 'airblade/vim-gitgutter'
    Plug 'folke/todo-comments.nvim'

    " Colorschemes plugins
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'morhetz/gruvbox'
    Plug 'EdenEast/nightfox.nvim'
    Plug 'arcticicestudio/nord-vim'
    Plug 'rose-pine/neovim'
    Plug 'catppuccin/nvim'
    Plug 'rebelot/kanagawa.nvim'

    " Plug 'chrisbra/Colorizer'
    " Plug 'wellle/context.vim'
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
    Plug 'catgoose/nvim-colorizer.lua'

    " Mr TPOPE
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'
    " Plug 'tpope/vim-fugitive'

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
    Plug 'RRethy/vim-illuminate'
    Plug 'nvim-tree/nvim-tree.lua'
    Plug 'windwp/nvim-autopairs'
    Plug 'windwp/nvim-ts-autotag'
    " Plug 'williamboman/mason.nvim'
    Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
    " Plug 'dense-analysis/ale'
    Plug 'rachartier/tiny-code-action.nvim'
    " Plug 'ahmedkhalf/project.nvim'
    Plug 'nvim-mini/mini.misc'
    Plug 'vuki656/package-info.nvim'
    Plug 'nmac427/guess-indent.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'mrcjkb/rustaceanvim'
    " Plug 'rebelot/heirline.nvim'
    " Plug 'akinsho/bufferline.nvim'
    Plug 'alvarosevilla95/luatab.nvim'
call plug#end()

:lua require('config')
