-- 3) say: when ft=edifact -> use parser edifact_vda4945
-- vim.treesitter.language.add("edifact", { path = "/home/dredd/.local/share/nvim/site/parser/parser.so" })
-- vim.treesitter.language.register("edifact", "edifact")

-- -- this line actually registers the query with Neovim
-- vim.treesitter.query.set("edifact_vda4945", "highlights", edi_highlight_query)
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   pattern = { "*.edi", "*.edifact", "*.iftsta" },
--   callback = function(args)
--     vim.bo[args.buf].filetype = "edifact"
--     vim.treesitter.start(args.buf, "edifact")
--   end,
-- })
--
vim.api.nvim_create_autocmd('User', {
  pattern = 'TSUpdate',
  callback = function()
    require('nvim-treesitter.parsers').edifact = {
      install_info = {
        path = '~/Projects/tree-sitter-edifact-vda4945',
      },
    }
  end,
})

require('nvim-treesitter.config').setup({
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
    'html',
    'angular',
    'kotlin',
    'edifact',
  },
  indent = { enable = true },
})

-- local parser_config = require('nvim-treesitter.parsers')

-- parser_config.edifact = {
--   install_info = {
--     url = '~/Projects/tree-sitter-edifact-vda4945',
--     files = { 'src/parser.c' },
--   },
--   filetype = 'edifact',
-- }

vim.treesitter.language.register('edifact', { 'edi', 'edifact', 'iftsta' })

vim.filetype.add {
  extension = {
    edi = 'edifact',
    edifact = 'edifact',
    itfsta = 'edifact',
  },
}

-- vim.treesitter.language.add("gleam", { path = "/home/diodredd/tree-sitters/tree-sitter-gleam/gleam.so" })
-- vim.treesitter.language.add("kotlin", { path = "/home/diodredd/tree-sitters/tree-sitter-kotlin/kotlin.so" })
