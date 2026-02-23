require('nvim-tree').setup({
  sort = {
    sorter = 'case_sensitive',
  },
  view = {
    width = 30,
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

