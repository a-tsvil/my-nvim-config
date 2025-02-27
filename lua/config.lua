-- main Lua-based configurations starts here
-- plugin-specific and separate configurations import
require('lang-servers')
require('lualine-setup')
require('nvim-cmp-config')
require('folding')
require('nvim-tree-config')

-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep:|,foldclose:]]
vim.opt.fillchars = { eob = ' ', fold = ' ', foldopen = '', foldclose = '' }
vim.opt.list = true

require('nvim-treesitter.configs').setup({
  highlight = { enable = true, disable = { 'vim', 'txt', 'help' } },
  ensure_installed = {
    'lua',
    'rust',
    'javascript',
    'typescript',
    'tsx',
    'json',
    'go',
    'yaml',
    'vim',
    'vimdoc',
    'php',
    'sql',
  },
  indent = { enable = true },
})

-- vim.treesitter.language.add("gleam", { path = "/home/diodredd/tree-sitters/tree-sitter-gleam/gleam.so" })
-- vim.treesitter.language.add("kotlin", { path = "/home/diodredd/tree-sitters/tree-sitter-kotlin/kotlin.so" })

local highlight = {
  'RainbowRed',
  'RainbowYellow',
  'RainbowBlue',
  'RainbowOrange',
  'RainbowGreen',
  'RainbowViolet',
  'RainbowCyan',
}

local hooks = require('ibl.hooks')
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
  vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
  vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
  vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
  vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
  vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
  vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
end)

require('ibl').setup({
  indent = { highlight = highlight },
  scope = { enabled = true },
})

require('todo-comments').setup({
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
})

require('diagflow').setup()
require('trouble').setup()

require('go').setup()

local format_sync_grp = vim.api.nvim_create_augroup('GoFormat', {})
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.go',
--   callback = function()
--     require('go.format').goimports()
--   end,
--   group = format_sync_grp,
-- })

require('lsp_signature').setup({
  floating_window = false,
})

require('aerial').setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
  end,
})

-- You probably also want to set a keymap to toggle aerial
vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')

require('luasnip.loaders.from_vscode').lazy_load()

require('nvim-autopairs').setup {}

require('nvim-ts-autotag').setup({
  opts = {
    -- Defaults
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = false, -- Auto close on trailing </
  },
  -- Also override individual filetype configs, these take priority.
  -- Empty by default, useful if one of the "opts" global settings
  -- doesn't work well in a specific filetype
  per_filetype = {
    ['html'] = {
      enable_close = false,
    },
  },
})

require('telescope').setup({
  pickers = {
    find_files = {
      hidden = true,
    },
  },
})
-- Telescope keymaps
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>')
vim.keymap.set('n', '<leader>fs', '<cmd>Telescope git_status<CR>')
