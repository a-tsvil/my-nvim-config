local M = {}
local patched = setmetatable({}, { __mode = 'k' })

local probe = table.concat({
  '````kotlin',
  'class String',
  '````',
}, '\n')

local function supports_multibacktick(markdown)
  local ok, blocks = pcall(markdown.parse, probe)
  return ok and blocks[1] and blocks[1].lang == 'kotlin'
end

local function opening_fence(line)
  return line and line:match('^%s*(```+)')
end

local function closes_fence(line, opening)
  local candidate = line and line:match('^%s*(`+)%s*$')
  return candidate ~= nil and #candidate >= #opening
end

local function parse(markdown, text, opts)
  opts = opts or {}
  text = text:gsub('</?pre>', '```'):gsub('\r', '')
  text = markdown.html_entities(text)

  local ret = {}
  local lines = vim.split(text, '\n')
  local l = 1

  local function eat_nl()
    while markdown.is_empty(lines[l + 1]) do
      l = l + 1
    end
  end

  while l <= #lines do
    local line = lines[l]
    if markdown.is_empty(line) then
      local is_start = l == 1
      eat_nl()
      local is_end = l == #lines
      if not (opening_fence(lines[l + 1]) or markdown.is_rule(lines[l + 1]) or is_start or is_end) then
        table.insert(ret, { line = '' })
      end
    elseif opening_fence(line) then
      local opening, info = line:match('^%s*(```+)%s*(.*)$')
      local lang = info:match('^([^%s`]+)') or opts.ft or 'text'
      local block = { lang = lang, code = {} }

      while lines[l + 1] and not closes_fence(lines[l + 1], opening) do
        table.insert(block.code, lines[l + 1])
        l = l + 1
      end

      local prev = ret[#ret]
      if prev and not markdown.is_rule(prev.line) then
        table.insert(ret, { line = '' })
      end

      table.insert(ret, block)
      l = l + 1
      eat_nl()
    elseif markdown.is_rule(line) then
      table.insert(ret, { line = '---' })
      eat_nl()
    else
      local prev = ret[#ret]
      if prev and prev.code then
        table.insert(ret, { line = '' })
      end
      table.insert(ret, { line = line })
    end
    l = l + 1
  end

  return ret
end

function M.setup(markdown)
  markdown = markdown or require('noice.text.markdown')

  if patched[markdown] or supports_multibacktick(markdown) then
    return false
  end

  markdown.parse = function(text, opts)
    return parse(markdown, text, opts)
  end
  patched[markdown] = true
  return true
end

return M
