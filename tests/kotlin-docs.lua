-- Run: nvim --headless -u NONE -i NONE -l tests/kotlin-docs.lua
vim.opt.runtimepath:append(vim.fn.getcwd())
for _, plugin in ipairs({ 'noice.nvim', 'nui.nvim', 'nvim-treesitter' }) do
  vim.opt.runtimepath:append(vim.fn.expand('~/.nvim/plugin/') .. plugin)
end

local docs = require('kotlin-docs')
local context = { client_id = 42, bufnr = vim.api.nvim_get_current_buf(), winid = vim.api.nvim_get_current_win() }
vim.api.nvim_buf_set_lines(context.bufnr, 0, -1, false, { 'GlobalOpenTelemetry.resetForTest()' })
local uri = 'jar:///tmp/source%20archive.jar!/io/opentelemetry/api/GlobalOpenTelemetry.java'
local args = vim.json.encode({ uri, 2, 3 })
local command = 'command:jetbrains.navigateToLocation?'
  .. args:gsub('[^%w]', function(char)
    return ('%%%02X'):format(char:byte())
  end)
local markdown = 'From class: [`GlobalOpenTelemetry`]('
  .. command
  .. ')\n\n'
  .. 'Unsets the global [OpenTelemetry](https://example.com/'
  .. string.rep('long/', 80)
  .. '). This is for tests.\n\n'
  .. '```text\nval example = "[literal](https://example.com)"\n```\n'
  .. 'Inline: `[literal](https://example.com)`\n'
  .. 'Unicode: é [nested](https://example.com/a_(b))\n'
  .. 'Angle: [source](<file:///tmp/a%20b.kt>)'
local compact = docs.compact(markdown, context)
assert(compact:find('[`GlobalOpenTelemetry`](kdoc:1)', 1, true))
assert(compact:find('[OpenTelemetry](kdoc:2). This is for tests.', 1, true))
assert(compact:find('val example = "[literal](https://example.com)"', 1, true))
assert(compact:find('Inline: `[literal](https://example.com)`', 1, true))
assert(compact:find('Unicode: é [nested](kdoc:3)', 1, true))
assert(compact:find('Angle: [source](kdoc:4)', 1, true))
assert(#compact < #markdown - 500)
local location = assert(docs.location(command))
assert(location.uri == uri)
assert(location.range.start.line == 2 and location.range.start.character == 3)
assert(docs.location('jar:///tmp/a.jar!/A.java').uri == 'jar:///tmp/a.jar!/A.java')
assert(docs.location('jrt:///java.base/java/lang/String.class').uri:match('^jrt:'))
assert(docs.location('<file:///tmp/a%20b.kt>').uri == 'file:///tmp/a%20b.kt')
assert(docs.location('https://example.com') == nil)
for _, invalid in ipairs({
  'command:jetbrains.other?%5B%5D',
  'command:jetbrains.navigateToLocation',
  'command:jetbrains.navigateToLocation?invalid',
  'command:jetbrains.navigateToLocation?%5B1%5D',
  'command:jetbrains.navigateToLocation?["file:///tmp/a",-1,0]',
}) do
  local value, err = docs.location(invalid)
  assert(not value and err)
end

-- Check dispatch and actual Neovim buffer/cursor behavior without starting a
-- project import or opening a browser. The RPC boundary is the only fake here.
local calls, opened, notices = {}, {}, {}
vim.notify = function(message)
  notices[#notices + 1] = message
end
require('noice.util').open = function(url)
  opened[#opened + 1] = url
end
local client = {
  id = 42,
  name = 'kotlin_lsp',
  offset_encoding = 'utf-16',
  is_stopped = function()
    return false
  end,
  request = function(_, method, params, callback, bufnr)
    calls[#calls + 1] = { method = method, params = params, bufnr = bufnr }
    callback(nil, { code = 'class GlobalOpenTelemetry {\n\n  éresetForTest();\n}', language = 'java' })
    return true, #calls
  end,
}
vim.lsp.get_client_by_id = function(id)
  return id == 42 and client or nil
end
vim.lsp.buf_attach_client = function(bufnr, id)
  assert(vim.bo[bufnr].readonly and id == 42)
  docs.attach(client, bufnr)
  return true
end
docs.open_link('kdoc:2')
assert(opened[1] == 'https://example.com/' .. string.rep('long/', 80))
docs.open_link('https://example.com/ordinary')
assert(opened[2] == 'https://example.com/ordinary')
docs.open_link('kdoc:1')
assert(calls[1].method == 'workspace/executeCommand')
assert(calls[1].params.command == 'decompile' and calls[1].params.arguments[1] == uri)
assert(calls[1].bufnr == context.bufnr)
local library_buf = vim.api.nvim_get_current_buf()
assert(vim.api.nvim_buf_get_name(library_buf) == uri)
assert(vim.bo[library_buf].readonly and not vim.bo[library_buf].modifiable)
assert(vim.bo[library_buf].filetype == 'java' and vim.bo[library_buf].buftype == 'nofile')
assert(not vim.bo[library_buf].modified)
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 3, 4 })) -- UTF-16 -> UTF-8 byte column
docs.open_link('kdoc:1')
assert(#calls == 1, 'Library sources should be cached')

-- Exercise Noice's real formatting, link keymap, and focus behavior.
vim.api.nvim_win_set_buf(context.winid, context.bufnr)
local config = require('noice.config')
config.options = config.defaults()
config.options.markdown.hover['%[.-%]%((%S-)%)'] = docs.open_link
local hover = require('noice.lsp.hover')
local messages = require('noice.lsp.docs')
messages.show = function() end
docs.setup()
docs.setup() -- reloading setup must not wrap the handler twice
hover.on_hover(nil, { contents = { kind = 'markdown', value = markdown } }, context)
local message = messages._messages.hover
local float_buf = vim.api.nvim_create_buf(false, true)
message:render(float_buf, config.ns)
local rendered = table.concat(vim.api.nvim_buf_get_lines(float_buf, 0, -1, false), '\n')
assert(rendered:find('kdoc:1', 1, true) and not rendered:find('command:jetbrains', 1, true))
local float = vim.api.nvim_open_win(float_buf, false, {
  relative = 'editor',
  row = 1,
  col = 1,
  width = 80,
  height = 12,
  style = 'minimal',
})
hover.on_hover(nil, { contents = { kind = 'markdown', value = '[different](file:///tmp/other.kt)' } }, context)
assert(vim.api.nvim_get_current_win() == float, 'Second K should focus the original hover')
require('noice.text.markdown').keys(float_buf)
local line = vim.api.nvim_get_current_line()
local col = assert(line:find('GlobalOpenTelemetry', 1, true))
vim.api.nvim_win_set_cursor(float, { 1, col - 1 })
vim.fn.maparg('gx', 'n', false, true).callback()
assert(vim.api.nvim_get_current_buf() == library_buf, 'gx should retain the first hover target after focus')
assert(#calls == 1)
vim.api.nvim_win_close(float, true)

for _, source_uri in ipairs({ 'jar:///tmp/raw.jar!/Raw.class', 'jrt:///java.base/java/lang/String.class' }) do
  docs.compact('[source](' .. source_uri .. ')', context)
  docs.open_link('kdoc:1')
  assert(calls[#calls].params.arguments[1] == source_uri)
  assert(vim.api.nvim_buf_get_name(0) == source_uri)
end
local source_file = vim.fn.tempname() .. ' source.kt'
vim.fn.writefile({ 'class Source' }, source_file)
docs.compact('[source](' .. vim.uri_from_fname(source_file) .. ')', context)
docs.open_link('kdoc:1')
assert(vim.api.nvim_buf_get_name(0) == source_file)
vim.fn.delete(source_file)

-- Go-to-definition uses the same source loader, with real cursor/tagstack
-- handling and the actual buffer-local mappings used by Kotlin's on_attach.
vim.api.nvim_win_set_buf(context.winid, context.bufnr)
vim.api.nvim_buf_set_lines(context.bufnr, 0, -1, false, { 'éGlobalOpenTelemetry.resetForTest()' })
vim.api.nvim_win_set_cursor(context.winid, { 1, 2 })
local original_get_clients = vim.lsp.get_clients
vim.lsp.get_clients = function(filter)
  assert(filter.bufnr == vim.api.nvim_get_current_buf() and filter.name == 'kotlin_lsp')
  assert(filter.method == 'textDocument/definition')
  return { client }
end
local definition_uri = 'jar:///tmp/definition.jar!/Library.java'
local definition_range = { start = { line = 2, character = 3 }, ['end'] = { line = 2, character = 16 } }
local definition_result = { uri = definition_uri, range = definition_range }
local definition_params, pending
local decompile_request = client.request
client.request = function(self, method, params, callback, bufnr)
  if method == 'textDocument/definition' then
    definition_params = params
    callback(nil, definition_result)
    return true, 123
  end
  return decompile_request(self, method, params, callback, bufnr)
end
docs.attach(client, context.bufnr)
vim.fn.maparg('gd', 'n', false, true).callback()
assert(definition_params.textDocument.uri == vim.uri_from_bufnr(context.bufnr))
assert(definition_params.position.character == 1, 'The request must use UTF-16 positions')
assert(vim.api.nvim_buf_get_name(0) == definition_uri and vim.bo.readonly)
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 3, 4 }))
assert(vim.fn.maparg('gd', 'n', false, true).buffer == 1, 'gd must also work inside library sources')
local tagstack = vim.fn.gettagstack(context.winid)
assert(tagstack.items[#tagstack.items].from[1] == context.bufnr)
vim.cmd('normal! ' .. vim.keycode('<C-o>'))
assert(vim.api.nvim_get_current_buf() == context.bufnr, 'Ctrl-o must return to the caller')
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 1, 2 }))

-- LocationLink must jump to the symbol's selection, rather than the enclosing
-- class range. Multiple results can be selected or canceled.
definition_result = {
  { uri = uri, range = definition_range },
  {
    targetUri = definition_uri,
    targetRange = { start = { line = 0, character = 0 }, ['end'] = { line = 3, character = 0 } },
    targetSelectionRange = definition_range,
  },
}
vim.ui.select = function(items, opts, callback)
  assert(#items == 2 and opts.format_item(items[2]):find('Library.java:3', 1, true))
  callback(nil)
end
docs.definition()
assert(vim.api.nvim_get_current_buf() == context.bufnr)
vim.ui.select = function(items, _, callback)
  callback(items[2])
end
docs.definition()
assert(vim.api.nvim_buf_get_name(0) == definition_uri)
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 3, 4 }))

-- Split mappings preserve the calling buffer and open the selected source in
-- the requested split, even when its buffer is already visible elsewhere.
for _, key in ipairs({ '<leader>v', '<leader>s' }) do
  vim.api.nvim_set_current_win(context.winid)
  vim.api.nvim_win_set_buf(context.winid, context.bufnr)
  vim.api.nvim_win_set_cursor(context.winid, { 1, 2 })
  local windows_before = #vim.api.nvim_list_wins()
  vim.fn.maparg(key, 'n', false, true).callback()
  assert(#vim.api.nvim_list_wins() == windows_before + 1)
  assert(vim.api.nvim_get_current_win() ~= context.winid and vim.api.nvim_buf_get_name(0) == definition_uri)
  assert(vim.api.nvim_win_get_buf(context.winid) == context.bufnr)
  vim.api.nvim_win_close(0, true)
end

-- Both definition and source-loading responses may arrive after the caller
-- moved. They should never pull the user back to an outdated target.
vim.api.nvim_set_current_win(context.winid)
vim.api.nvim_win_set_cursor(context.winid, { 1, 2 })
client.request = function(_, _, _, callback)
  pending = callback
  return true, 124
end
docs.definition()
vim.api.nvim_win_set_cursor(context.winid, { 1, 3 })
pending(nil, { uri = definition_uri, range = definition_range })
assert(vim.api.nvim_get_current_buf() == context.bufnr)
vim.api.nvim_win_set_cursor(context.winid, { 1, 2 })
docs.definition()
pending(nil, { uri = 'jar:///tmp/delayed.jar!/Delayed.java', range = definition_range })
vim.api.nvim_win_set_cursor(context.winid, { 1, 3 })
pending(nil, { code = 'class Delayed {}', language = 'java' })
assert(vim.api.nvim_get_current_buf() == context.bufnr)
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 1, 3 }))

client.request = function(_, _, _, callback)
  callback(nil, {})
end
docs.definition()
assert(vim.api.nvim_get_current_buf() == context.bufnr and notices[#notices] == 'No definition found')
client.request = function(_, _, _, callback)
  callback({ message = 'Definition failed' }, nil)
end
docs.definition()
assert(vim.api.nvim_get_current_buf() == context.bufnr and notices[#notices]:find('Definition failed', 1, true))

-- Errors must leave the current source alone.
local original_buf = vim.api.nvim_get_current_buf()
docs.compact('[broken](jar:///tmp/broken.jar!/Broken.class)', context)
client.request = function(_, _, _, callback)
  callback({ message = 'Missing archive' }, nil)
end
docs.open_link('kdoc:1')
assert(vim.api.nvim_get_current_buf() == original_buf)
assert(notices[#notices]:find('Missing archive', 1, true))
vim.lsp.get_clients = original_get_clients
print('Kotlin documentation checks passed')
