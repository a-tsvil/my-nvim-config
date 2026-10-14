local M = {}
local links = {}
local configured = false
local destination_query

local function warn(message)
  vim.notify(message, vim.log.levels.WARN, { title = 'Kotlin documentation' })
end

local function decode(text)
  return (text:gsub('%%(%x%x)', function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

-- Keep short destinations in the rendered buffer. Concealed URLs still affect
-- wrapping and float dimensions, especially the encoded command arguments.
-- Tree-sitter avoids rewriting examples in code blocks or inline code, and
-- handles nested parentheses/backticks in Markdown links.
function M.compact(markdown, context)
  local parser = vim.treesitter.get_string_parser(markdown, 'markdown')
  parser:parse(true)
  destination_query = destination_query
    or vim.treesitter.query.parse('markdown_inline', '(inline_link (link_destination) @url)')
  local replacements = {}
  parser:for_each_tree(function(tree, language_tree)
    if language_tree:lang() ~= 'markdown_inline' then
      return
    end
    for _, node in destination_query:iter_captures(tree:root(), markdown) do
      local _, _, first, _, _, last = node:range(true)
      replacements[#replacements + 1] = {
        first = first,
        last = last,
        url = vim.treesitter.get_node_text(node, markdown),
      }
    end
  end)
  table.sort(replacements, function(a, b)
    return a.first < b.first
  end)

  links = {}
  local parts, offset = {}, 0
  for id, replacement in ipairs(replacements) do
    local alias = 'kdoc:' .. id
    links[alias] = vim.tbl_extend('force', context, { url = replacement.url })
    parts[#parts + 1] = markdown:sub(offset + 1, replacement.first)
    parts[#parts + 1] = alias
    offset = replacement.last
  end
  parts[#parts + 1] = markdown:sub(offset + 1)
  return table.concat(parts)
end

function M.location(url)
  url = url:gsub('^<', ''):gsub('>$', '')
  if url:match('^command:') then
    local command, encoded = url:match('^command:([^?]+)%?(.*)$')
    if command ~= 'jetbrains.navigateToLocation' then
      return nil, 'Unsupported documentation command: ' .. (command or url)
    end
    local ok, args = pcall(vim.json.decode, decode(encoded))
    if not ok or type(args) ~= 'table' or type(args[1]) ~= 'string' then
      return nil, 'Invalid navigation link arguments'
    end
    local line, character = args[2], args[3]
    if
      type(line) ~= 'number'
      or type(character) ~= 'number'
      or line < 0
      or character < 0
      or line % 1 ~= 0
      or character % 1 ~= 0
    then
      return nil, 'Invalid navigation link position'
    end
    local position = { line = line, character = character }
    return { uri = args[1], range = { start = position, ['end'] = position } }
  end
  if url:match('^jar:') or url:match('^jrt:') or url:match('^file:') then
    return { uri = url }
  end
end

local function jump(location, link, client)
  if link.is_valid and not link.is_valid() then
    return
  end
  if not vim.api.nvim_win_is_valid(link.winid) then
    warn('The source window has been closed')
    return
  end
  vim.api.nvim_set_current_win(link.winid)
  if link.split then
    vim.cmd(link.split)
  end
  vim.lsp.util.show_document(location, client.offset_encoding, { reuse_win = not link.split, focus = true })
end

function M.open_link(alias)
  local link = links[alias]
  if not link then
    if alias:match('^kdoc:') then
      warn('This documentation link has expired; reopen the hover')
      return
    end
    return require('noice.util').open(alias)
  end
  local location, err = M.location(link.url)
  if err then
    warn(err)
    return
  end
  if not location then
    return require('noice.util').open(link.url:gsub('^<', ''):gsub('>$', ''))
  end
  return M.open_location(location, link)
end

-- Shared by hover links and go-to-definition. Library contents must be loaded
-- before show_document can translate the server's position into a byte column.
function M.open_location(location, link)
  location = {
    uri = location.uri or location.targetUri,
    range = location.targetSelectionRange or location.range,
  }
  if not location.uri then
    warn('No source URI in the navigation result')
    return
  end
  if not location.uri:match('^file:') and not location.uri:match('^jar:') and not location.uri:match('^jrt:') then
    warn('Unsupported source URI: ' .. location.uri)
    return
  end
  local client = vim.lsp.get_client_by_id(link.client_id)
  if not client or client:is_stopped() then
    warn('The Kotlin language server is no longer running')
    return
  end
  if location.uri:match('^file:') then
    jump(location, link, client)
    return
  end

  local bufnr = vim.uri_to_bufnr(location.uri)
  if vim.b[bufnr].kotlin_source_loaded then
    jump(location, link, client)
    return
  end
  -- Same protocol as JetBrains' VS Code client; it also works for .class files
  -- and JDK sources, where unzip alone cannot provide readable source text.
  client:request('workspace/executeCommand', {
    command = 'decompile',
    arguments = { location.uri },
  }, function(request_err, result)
    if request_err or type(result) ~= 'table' or type(result.code) ~= 'string' then
      warn('Cannot load library source: ' .. (request_err and request_err.message or location.uri))
      return
    end
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    vim.bo[bufnr].buftype = 'nofile'
    vim.bo[bufnr].bufhidden = 'hide'
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(result.code, '\n', { plain = true }))
    vim.bo[bufnr].filetype = result.language == 'kotlin' and 'kotlin' or 'java'
    vim.bo[bufnr].modified = false
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].readonly = true
    vim.b[bufnr].kotlin_source_loaded = true
    vim.lsp.buf_attach_client(bufnr, client.id)
    jump(location, link, client)
  end, link.bufnr)
end

function M.definition(opts)
  opts = opts or {}
  local bufnr, winid = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'kotlin_lsp', method = 'textDocument/definition' })[1]
  if not client then
    return vim.lsp.buf.definition()
  end
  local cursor = vim.api.nvim_win_get_cursor(winid)
  local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
  local function is_valid()
    return vim.api.nvim_win_is_valid(winid)
      and vim.api.nvim_get_current_win() == winid
      and vim.api.nvim_win_get_buf(winid) == bufnr
      and vim.api.nvim_buf_get_changedtick(bufnr) == changedtick
      and vim.deep_equal(vim.api.nvim_win_get_cursor(winid), cursor)
  end
  local context = {
    client_id = client.id,
    bufnr = bufnr,
    winid = winid,
    split = opts.split,
    is_valid = is_valid,
  }
  client:request(
    'textDocument/definition',
    vim.lsp.util.make_position_params(winid, client.offset_encoding),
    function(err, result)
      if not is_valid() then
        return
      end
      if err then
        warn('Cannot find definition: ' .. err.message)
        return
      end
      if not result or result == vim.NIL or (vim.islist(result) and #result == 0) then
        vim.notify('No definition found', vim.log.levels.INFO)
        return
      end
      local locations = vim.islist(result) and result or { result }
      if #locations == 1 then
        return M.open_location(locations[1], context)
      end
      vim.ui.select(locations, {
        prompt = 'Kotlin definitions',
        format_item = function(location)
          local uri = location.uri or location.targetUri or ''
          local range = location.targetSelectionRange or location.range
          return decode(uri) .. (range and ':' .. (range.start.line + 1) or '')
        end,
      }, function(location)
        if location and is_valid() then
          M.open_location(location, context)
        end
      end)
    end,
    bufnr
  )
end

function M.attach(client, bufnr)
  if client.name ~= 'kotlin_lsp' then
    return
  end
  vim.keymap.set('n', 'gd', function()
    M.definition()
  end, { buffer = bufnr, silent = true, desc = 'Kotlin definition (including library sources)' })
  vim.keymap.set('n', '<leader>v', function()
    M.definition({ split = 'vsplit' })
  end, { buffer = bufnr, silent = true, desc = 'Kotlin definition in a vertical split' })
  vim.keymap.set('n', '<leader>s', function()
    M.definition({ split = 'belowright split' })
  end, { buffer = bufnr, silent = true, desc = 'Kotlin definition in a horizontal split' })
end

function M.setup()
  if configured then
    return
  end
  local hover = require('noice.lsp.hover')
  local original = hover.on_hover
  configured = true
  hover.on_hover = function(err, result, ctx, config)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if err or not client or client.name ~= 'kotlin_lsp' or not result or not result.contents then
      return original(err, result, ctx, config)
    end
    if vim.api.nvim_get_current_buf() ~= ctx.bufnr then
      return
    end
    -- Focusing existing docs must retain the aliases used by that buffer.
    local message = require('noice.lsp.docs')._messages.hover
    if message and message:focus() then
      return
    end
    if type(result.contents) == 'table' and result.contents.kind == 'plaintext' then
      return original(err, result, ctx, config)
    end
    local markdown = table.concat(require('noice.lsp.format').format_markdown(result.contents), '\n')
    local ok, compact = pcall(M.compact, markdown, {
      client_id = ctx.client_id,
      bufnr = ctx.bufnr,
      winid = vim.api.nvim_get_current_win(),
    })
    if not ok then
      warn('Cannot parse hover Markdown: ' .. compact)
      return original(err, result, ctx, config)
    end
    local formatted = vim.tbl_extend('force', result, { contents = { kind = 'markdown', value = compact } })
    return original(err, formatted, ctx, config)
  end
end

return M
