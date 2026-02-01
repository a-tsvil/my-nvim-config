-- main Lua-based configurations starts here

-- General settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard:append('unnamedplus')
vim.opt.wrap = false
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = { trail = '⋅', tab = '│ ' }
vim.opt.conceallevel = 2
vim.opt.signcolumn = 'yes'
vim.opt.equalalways = false

-- Color scheme
vim.cmd('colorscheme kanagawa')
vim.api.nvim_set_hl(0, 'Visual', { reverse = true })
vim.g.nord_contrast = false
vim.g.nord_borders = true
vim.g.nord_disable_background = false
vim.g.nord_italic = false
vim.g.nord_uniform_diff_background = true
vim.g.nord_bold = false
vim.g.nord_cursorline_transparent = true

-- Colorizer
vim.g.colorizer_auto_filetype = 'css,scss,html,js,jsx,ts,tsx,svelte'

-- Neovide config
if vim.g.neovide then
  vim.opt.guifont = 'Iosevka Curly:h15'
  -- vim.opt.guifont = 'Victor Mono:h15.5'
  vim.g.neovide_scroll_animation_length = 0.55
  vim.g.neovide_opacity = 0.9
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_refresh_rate = 2000
  -- vim.g.neovide_fullscreen = true
  -- vim.g.neovide_cursor_vfx_mode = 'sonicboom'
end

-- File history mapping
--
-- vim.g.fzf_history_options = '--with-nth=-1'
-- vim.keymap.set('n', '<leader>m', ':History<CR>', { silent = true })
-- vim.cmd([[
-- command! -bang -nargs=* History
--       \ call fzf#vim#history({
--       \   'options': ['--delimiter=/', '--with-nth=-3..-1']
--       \ }, <bang>0)
-- ]])
-- vim.keymap.set(
--   'n',
--   '<leader>m',
--   ':History! -- --delimiter=/ --with-nth=-1<CR>',
--   { silent = true }
-- )
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>m', function()
  builtin.oldfiles({
    path_display = { "smart" },
    previewer = true,
  })
end, { silent = true })

-- NvimTree mappings
vim.g.NERDTreeShowHidden = 1
vim.keymap.set('n', '<leader>r', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<leader>nvt', ':NvimTreeOpen<CR>')

-- Rust formatting
vim.keymap.set('n', 'rf', ':%! rustfmt<CR>')

-- Commentary plugin mappings
vim.cmd('filetype plugin indent on')
vim.keymap.set('n', 'gc', ':Commentary<CR>')
vim.keymap.set('n', 'gcc', ':Commentary<CR>')

-- CtrlP
vim.g.ctrlp_map = '<C-p>'
vim.g.ctrlp_cmd = 'CtrlP'

-- Neoformat config
vim.g.neoformat_try_node_exe = 1
-- vim.g.neoformat_verbose = 1
vim.keymap.set('n', '<leader>fm', ':Neoformat<CR>')
vim.keymap.set('n', '<leader>fmp', ':Neoformat prettier<CR>')

vim.g.neoformat_php_phpcsfixer = {
  exe = './vendor/bin/php-cs-fixer',
  args = { 'fix' },
  env = { 'PHP_CS_FIXER_IGNORE_ENV=1' },
  replace = 1,
}
vim.g.neoformat_enabled_php = { 'phpcsfixer' }

vim.g.neoformat_htmlangular_prettierd = {
  exe = 'prettierd',
  args = { '--stdin-filepath', '%:p' },
  stdin = 1,
}

-- vim.g.neoformat_enabled_htmlangular = { 'biome' }
-- vim.g.neoformat_enabled_javascript = { 'biome' }
-- vim.g.neoformat_enabled_typescript = { 'biome' }
-- vim.g.neoformat_enabled_typescriptreact = { 'biome' }

vim.g.neoformat_enabled_htmlangular = { 'eslint_d' }
vim.g.neoformat_enabled_javascript = { 'eslint_d' }
vim.g.neoformat_enabled_typescript = { 'eslint_d' }
vim.g.neoformat_enabled_typescriptreact = { 'eslint_d' }

vim.g.neoformat_enabled_python = { 'ruff' }

-- plugin-specific and separate configurations import
require('lang-servers')
require('lualine-setup')
require('nvim-cmp-config')
require('folding')
require('nvim-tree-config')
require('tree-sitter')
-- require('cursor')

-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep:|,foldclose:]]
vim.opt.fillchars = { eob = ' ', fold = ' ', foldopen = '', foldclose = '' }
vim.opt.list = true

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

-- require('diagflow').setup()
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

-- require 'lsp_signature'.setup({
--   handler_opts = {
--     border = 'rounded',
--   },
--   -- Avoid triggering on empty lines
--   on_attach = function(client, bufnr)
--     local sig = require 'lsp_signature'
--     local function on_insert_char_pre()
--       local line = vim.api.nvim_get_current_line()
--       if line:match('^%s*$') then
--         sig.on_detach()
--       end
--     end
--     vim.api.nvim_create_autocmd('InsertCharPre', {
--       buffer = bufnr,
--       callback = on_insert_char_pre,
--     })
--   end,
-- })

require('aerial').setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer

  manage_folds = true,

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
  enable = true,
  filetypes = { 'html', 'xml', 'tsx', 'angular', 'htmlangular' },
  opts = {

    -- Defaults
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = false, -- Auto close on trailing </
  },
  -- Also override individual filetype configs, these take priority.
  -- Empty by default, useful if one of the "opts" global settings
  -- doesn't work well in a specific filetype
  -- per_filetype = {
  --   ['html'] = {
  --     enable_close = false,
  --   },
  -- },
})

require('telescope').setup({
  file_ignore_patterns = {
    'node_modules/',
    '%.git/',
    'dist/',
    'build/',
    'venv/',
  },
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

vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { buffer = bufnr })

-- Diagnostics configuration
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = { 'typescript' },
--   callback = function()
--     local bufnr = vim.api.nvim_get_current_buf()
--     vim.diagnostic.config({
--       virtual_text = false,
--       signs = true,
--       underline = true,
--     }, bufnr)
--   end,
-- })
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
})
vim.o.updatetime = 100
vim.api.nvim_create_autocmd({ 'CursorHold' }, {
  pattern = '*',
  callback = function()
    for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(winid).zindex then
        return
      end
    end
    vim.diagnostic.open_float {
      scope = 'cursor',
      focusable = false,
      close_events = {
        'CursorMoved',
        'CursorMovedI',
        'BufHidden',
        'InsertCharPre',
        'WinLeave',
      },
    }
  end,
})

require('illuminate').configure({})

local link_visual = {
  'IlluminatedWordText',
  'IlluminatedWordRead',
  'IlluminatedWordWrite',
}

for _, group in ipairs(link_visual) do
  vim.api.nvim_set_hl(0, group, { link = 'Visual' })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    for _, group in ipairs(link_visual) do
      vim.api.nvim_set_hl(0, group, { link = 'Visual' })
    end
  end,
})

vim.o.splitright = true
vim.keymap.set('n', '<leader>v', ':vsplit | lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', '<leader>s', ':belowright split | lua vim.lsp.buf.definition()<CR>')

require('colorizer').setup()

-- require('project_nvim').setup {
--   -- your configuration comes here
--   -- or leave it empty to use the default settings
--   -- refer to the configuration section below
-- }

require('mini.misc').setup {
  make_global = { 'put', 'put_text', 'setup_auto_root' },
}

require('package-info').setup {
  autostart = true,
}

require('package-info').setup()
require('telescope').load_extension('package_info')

require('guess-indent').setup {}

require('gitsigns').setup {
  signs = {
    add = { text = '┃' },
    change = { text = '┃' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '┆' },
  },
  signs_staged = {
    add = { text = '┃' },
    change = { text = '┃' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true,
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },
}

vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns blame<CR>')

-- require("heirline").setup({})

-- require("bufferline").setup{}

require('luatab').setup {}

-- require('overlength').setup({
--   -- Overlength highlighting enabled by default
--   enabled = true,

--   -- Colors for OverLength highlight group
--   colors = {
--     ctermfg = nil,
--     ctermbg = 'darkgrey',
--     fg = nil,
--     bg = '#8B0000',
--   },

--   -- Mode to use textwidth local options
--   -- 0: Don't use textwidth at all, always use config.default_overlength.
--   -- 1: Use `textwidth, unless it's 0, then use config.default_overlength.
--   -- 2: Always use textwidth. There will be no highlighting where
--   --    textwidth == 0, unless added explicitly
--   textwidth_mode = 2,
--   -- Default overlength with no filetype
--   default_overlength = 80,
--   -- How many spaces past your overlength to start highlighting
--   grace_length = 1,
--   -- Highlight only the column or until the end of the line
--   highlight_to_eol = true,

--   -- List of filetypes to disable overlength highlighting
--   disable_ft = {
--     'qf',
--     'help',
--     'man',
--     'checkhealth',
--     'lazy',
--     'packer',
--     'NvimTree',
--     'Telescope',
--     'TelescopePrompt',
--     'TelescopeResults',
--     'WhichKey',
--   },
-- })
