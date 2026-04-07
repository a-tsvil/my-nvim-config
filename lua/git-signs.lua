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
  diff_opts = {
    internal = true,
    algorithm = 'histogram',
    -- Bigger rewrites usually render better when GitSigns can do a second pass.
    linematch = 60,
  },
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

local gitsigns = require('gitsigns')

local function toggle_hunk_popup()
  local popup = require('gitsigns.popup')
  if popup.is_open('hunk') then
    popup.close('hunk')
    return
  end

  gitsigns.preview_hunk()
end

local function toggle_file_diff(base)
  return function()
    if vim.wo.diff then
      vim.cmd('diffoff!')
      return
    end

    gitsigns.diffthis(base)
  end
end

vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns blame<CR>')
vim.keymap.set('n', '<leader>gp', toggle_hunk_popup)
vim.keymap.set('n', '<leader>gpl', function()
  gitsigns.preview_hunk_inline()
end)
vim.keymap.set('n', '<leader>gd', toggle_file_diff())
vim.keymap.set('n', '<leader>gD', toggle_file_diff('HEAD'))
vim.keymap.set('n', '<leader>gw', function()
  gitsigns.toggle_word_diff()
end)
