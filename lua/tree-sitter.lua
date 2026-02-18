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

local parser_config = require("nvim-treesitter.parsers")

-- NOTE: for now building kotlin parser directly from sources fwcd/tree-sitter-kotlin (#main) for last changes
parser_config.kotlin = {
  install_info = {
    url = "https://github.com/fwcd/tree-sitter-kotlin",
    branch = "main",
    files = { "src/parser.c", "src/scanner.c" },
  },
  filetype = "kotlin",
}

require("nvim-treesitter").setup({
  install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
})

local languages = {
  "lua",
  "rust",
  "javascript",
  "typescript",
  "tsx",
  "json",
  "java",
  "javadoc",
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

require("nvim-treesitter").install(languages)

-- Centralized Tree-sitter attach point.
-- We intentionally keep this in one place instead of per-filetype ftplugins so
-- Kotlin/TS and other languages behave consistently.
local ts_start_group = vim.api.nvim_create_augroup("ConfigTreeSitterStart", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = ts_start_group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    if vim.b[args.buf].ts_started then
      return
    end

    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then
      return
    end
    vim.b[args.buf].ts_started = true
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
