vim.o.foldenable = false
vim.o.foldcolumn = '1'
vim.o.foldmethod = 'expr'
vim.o.foldlevelstart = 99

vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
