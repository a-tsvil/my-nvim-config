local plug_path = vim.fn.expand('~/.nvim/plugin')
local Plug = vim.fn['plug#']

vim.fn['plug#begin'](plug_path)

Plug('lukas-reineke/indent-blankline.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('nvim-tree/nvim-web-devicons')
Plug('ryanoasis/vim-devicons')

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('junegunn/fzf', {
  ['do'] = function()
    vim.fn['fzf#install']()
  end,
})
Plug('junegunn/fzf.vim')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')

Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp-signature-help')
Plug('saadparwaiz1/cmp_luasnip')
Plug('L3MON4D3/LuaSnip')
Plug('Jezda1337/nvim-html-css')

Plug('neovim/nvim-lspconfig')
Plug('ray-x/lsp_signature.nvim')

Plug('folke/todo-comments.nvim')

Plug('folke/tokyonight.nvim', { branch = 'main' })
Plug('morhetz/gruvbox')
Plug('EdenEast/nightfox.nvim')
Plug('arcticicestudio/nord-vim')
Plug('rose-pine/neovim')
Plug('catppuccin/nvim')
Plug('rebelot/kanagawa.nvim')
Plug('sainnhe/everforest')

Plug('mg979/vim-visual-multi', { branch = 'master' })
Plug('catgoose/nvim-colorizer.lua')

Plug('tpope/vim-commentary')
Plug('tpope/vim-surround')

Plug('rust-lang/rust.vim')
Plug('hashivim/vim-terraform')
Plug('prisma/vim-prisma')
Plug('ray-x/go.nvim')
Plug('ray-x/guihua.lua')

Plug('ctrlpvim/ctrlp.vim')
Plug('sbdchd/neoformat')
Plug('folke/trouble.nvim')
Plug('dgagn/diagflow.nvim')
Plug('stevearc/aerial.nvim')
Plug('rafamadriz/friendly-snippets')
Plug('RRethy/vim-illuminate')
Plug('nvim-tree/nvim-tree.lua')
Plug('windwp/nvim-autopairs')
Plug('windwp/nvim-ts-autotag')
Plug('rachartier/tiny-code-action.nvim')
Plug('nvim-mini/mini.misc')
Plug('vuki656/package-info.nvim')
Plug('nmac427/guess-indent.nvim')
Plug('lewis6991/gitsigns.nvim')
Plug('mrcjkb/rustaceanvim')
Plug('alvarosevilla95/luatab.nvim')
Plug('iamcco/markdown-preview.nvim', { ['do'] = 'cd app && npx --yes yarn install' })
Plug('mason-org/mason.nvim')
Plug('sindrets/diffview.nvim')

Plug('folke/noice.nvim')
Plug('MunifTanjim/nui.nvim')
Plug('rcarriga/nvim-notify')

vim.fn['plug#end']()

require('config')
