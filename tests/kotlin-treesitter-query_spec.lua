local config_root = vim.fn.getcwd()
local installed_site = vim.fs.joinpath(vim.fn.stdpath('data'), 'site')

vim.opt.runtimepath:prepend(installed_site)
vim.opt.runtimepath:prepend(config_root)
vim.opt.runtimepath:append(vim.fs.joinpath(config_root, 'after'))

local function assert_true(value, message)
  if not value then
    error(message)
  end
end

assert_true(vim.treesitter.language.add('kotlin'), 'failed to load the installed Kotlin parser')

local query = assert(vim.treesitter.query.get('kotlin', 'highlights'))
local query_files = vim.treesitter.query.get_files('kotlin', 'highlights')
assert_true(
  vim.list_contains(query_files, vim.fs.joinpath(config_root, 'after/queries/kotlin/highlights.scm')),
  'missing the Kotlin after-query extension'
)

local bufnr = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
  'class Greeter(val name: String) {',
  '  fun greet(target: String) = "Hello, ${target}"',
  '  fun call() = greet(target = name)',
  '}',
})

local parser = vim.treesitter.get_parser(bufnr, 'kotlin')
local tree = assert(parser:parse()[1])
local captures = {}

for capture_id in query:iter_captures(tree:root(), bufnr, 0, -1) do
  captures[query.captures[capture_id]] = true
end

assert_true(captures['keyword.type'], 'missing Kotlin class keyword capture')
assert_true(captures['type.builtin'], 'missing Kotlin built-in type capture')
assert_true(captures.string, 'missing Kotlin string capture')
assert_true(captures['punctuation.special'], 'missing Kotlin interpolation capture')
assert_true(captures.property, 'missing named-argument property extension capture')

local started, start_error = pcall(vim.treesitter.start, bufnr, 'kotlin')
assert_true(started, start_error)
assert_true(vim.treesitter.highlighter.active[bufnr] ~= nil, 'regular-buffer highlighter did not start')

print('kotlin-treesitter-query: ok')
