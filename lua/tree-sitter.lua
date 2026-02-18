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
-- Use fwcd/tree-sitter-kotlin (main) as the Kotlin parser source
local parser_config = require("nvim-treesitter.parsers")

parser_config.kotlin = {
  install_info = {
    url = "https://github.com/fwcd/tree-sitter-kotlin",
    branch = "main",
    files = { "src/parser.c", "src/scanner.c" },
  },
  filetype = "kotlin",
}

-- New nvim-treesitter is used for parser/query installation.
-- Highlight attachment itself is done via vim.treesitter.start().
require("nvim-treesitter").setup()

-- Languages you want installed
local languages = {
  "lua",
  "rust",
  "javascript",
  "typescript",
  "tsx",
  "json",
  "go",
  "yaml",
  "vim",
  "vimdoc",
  "php",
  "sql",
  "html",
  -- "angular",
  "kotlin",
  "edifact",
  "groovy",
  "markdown",
  "markdown_inline",
}

-- Install them (async)
require("nvim-treesitter").install(languages)

local ts_start_group = vim.api.nvim_create_augroup("ConfigTreeSitterStart", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType" }, {
  group = ts_start_group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    pcall(vim.treesitter.start, args.buf)
  end,
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

local function apply_treesitter_links()
  vim.api.nvim_set_hl(0, "@property", { link = "@variable.member" })
end

apply_treesitter_links()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_treesitter_links,
})
