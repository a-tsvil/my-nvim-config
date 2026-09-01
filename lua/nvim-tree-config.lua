require('nvim-tree').setup({
  auto_reload_on_write = true,
  reload_on_bufenter = true,
  filesystem_watchers = {
    enable = true,
  },
  sort = {
    sorter = 'case_sensitive',
  },
  view = {
    width = 40,
    -- adaptive_size = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
    git_ignored = false,
  },
})

-- NvimTree mappings
vim.g.NERDTreeShowHidden = 1
vim.keymap.set('n', '<leader>r', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<leader>nvt', ':NvimTreeOpen<CR>')
