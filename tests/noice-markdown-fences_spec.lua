local paths = {
  vim.fn.getcwd(),
  vim.fn.expand('~/.nvim/plugin/noice.nvim'),
  vim.fn.expand('~/.nvim/plugin/nui.nvim'),
}

for _, path in ipairs(paths) do
  vim.opt.runtimepath:prepend(path)
  package.path = table.concat({
    path .. '/lua/?.lua',
    path .. '/lua/?/init.lua',
    package.path,
  }, ';')
end

local function assert_equal(actual, expected, message)
  if not vim.deep_equal(actual, expected) then
    error(('%s\nexpected: %s\nactual: %s'):format(message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local kotlin_hover = table.concat({
  '````kotlin',
  'class String : Comparable<String>, CharSequence, java.io.Serializable',
  '````',
}, '\n')

local triple_kotlin = table.concat({
  '```kotlin',
  'class String',
  '```',
}, '\n')

local nested_shorter_fence = table.concat({
  '````kotlin',
  'class String',
  '```',
  '````',
}, '\n')

local ordinary_markdown = table.concat({
  'Intro &amp; details',
  '',
  '---',
  '',
  'More prose',
}, '\n')

local markdown = require('noice.text.markdown')
local original_triple = markdown.parse(triple_kotlin)
local original_ordinary = markdown.parse(ordinary_markdown)
assert_equal(markdown.parse(kotlin_hover)[1].lang, '`kotlin', 'reproduces the installed Noice fence bug')

local shim = require('noice-markdown-fences')

assert_equal(shim.setup(markdown), true, 'installs against the broken parser')

local parsed_hover = markdown.parse(kotlin_hover)
assert_equal(parsed_hover[1].lang, 'kotlin', 'extracts the full-fence language')
assert_equal(
  parsed_hover[1].code,
  { 'class String : Comparable<String>, CharSequence, java.io.Serializable' },
  'preserves the declaration'
)
assert_equal(markdown.parse(triple_kotlin), original_triple, 'preserves triple-fence behavior')
assert_equal(markdown.parse(ordinary_markdown), original_ordinary, 'preserves ordinary Markdown behavior')
assert_equal(
  markdown.parse(nested_shorter_fence)[1].code,
  { 'class String', '```' },
  'keeps a shorter fence inside the outer block'
)
assert_equal(shim.setup(markdown), false, 'is idempotent')

local upstream_parse = function()
  return { { lang = 'kotlin', code = { 'class String' } } }
end
local upstream_markdown = { parse = upstream_parse }
assert_equal(shim.setup(upstream_markdown), false, 'skips a parser with upstream support')
assert_equal(upstream_markdown.parse, upstream_parse, 'preserves the upstream parser')

print('noice-markdown-fences: ok')
