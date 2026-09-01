# Noice Multi-Backtick LSP Documentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Noice recognize Kotlin LSP's four-backtick Markdown code fences so Kotlin syntax highlighting runs in hover and completion documentation.

**Architecture:** Add a runtime compatibility module that feature-tests Noice's exported Markdown parser and replaces only that parser when multi-backtick support is absent. Load the shim after Noice setup; a headless test exercises the exact Kotlin LSP payload and the parser's fence semantics.

**Tech Stack:** Neovim 0.12 Lua API, Noice Markdown renderer, Tree-sitter Kotlin parser, headless Neovim tests, StyLua.

## Global Constraints

- Do not stage or commit any files.
- Do not edit or update the managed `noice.nvim` plugin.
- Preserve the user's existing `lua/nvim-tree-config.lua` changes.
- Preserve ordinary prose, rules, blank-line, HTML-entity, and triple-backtick behavior.
- Make the shim a no-op when Noice already supports four-backtick fences.

## File Map

- Create: `lua/noice-markdown-fences.lua`
  - Owns feature detection and the fence-aware compatibility parser.
- Create: `tests/noice-markdown-fences_spec.lua`
  - Covers the captured Kotlin payload, triple fences, nested shorter fences, idempotence, and future upstream support.
- Modify: `lua/config.lua:480-498`
  - Activates the compatibility module after Noice setup.
- Verify: `lua/treesitter-highlight-links.lua`
  - Existing Kotlin capture fallbacks remain unchanged and green.

---

### Task 1: Specify Multi-Backtick Parsing

**Files:**

- Create: `tests/noice-markdown-fences_spec.lua`

**Interfaces:**

- Consumes: installed `noice.text.markdown.parse(text, opts?)`.
- Produces: executable behavioral requirements for `require("noice-markdown-fences").setup(markdown?)`.

- [ ] **Step 1: Add the isolated Noice test harness**

Create `tests/noice-markdown-fences_spec.lua`. Add this config, Noice, and Nui
to `runtimepath` and `package.path` without loading the user's full init:

```lua
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
```

- [ ] **Step 2: Add tests for the exact payload and fence behavior**

Build literal fixtures for:

```lua
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
```

Before loading the shim, assert that the installed parser reports
`` `kotlin `` for the captured payload. Preserve the original triple-fence
result, then call:

```lua
local markdown = require('noice.text.markdown')
local original_triple = markdown.parse(triple_kotlin)
local original_ordinary = markdown.parse(ordinary_markdown)
assert_equal(
  markdown.parse(kotlin_hover)[1].lang,
  '`kotlin',
  'reproduces the installed Noice fence bug'
)

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
```

- [ ] **Step 3: Run the test and verify RED**

Run:

```bash
nvim --clean --headless -u NONE -l tests/noice-markdown-fences_spec.lua
```

Expected: non-zero exit because `noice-markdown-fences` does not exist.

### Task 2: Implement the Compatibility Parser

**Files:**

- Create: `lua/noice-markdown-fences.lua`
- Test: `tests/noice-markdown-fences_spec.lua`

**Interfaces:**

- Consumes: a Noice Markdown module with `parse`, `html_entities`,
  `is_empty`, and `is_rule`.
- Produces: `setup(markdown?) -> boolean`; returns `true` only when it installs
  the compatibility parser.

- [ ] **Step 1: Add feature detection and fence helpers**

Create `lua/noice-markdown-fences.lua` with:

```lua
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
```

- [ ] **Step 2: Implement the fence-aware parser**

Add the fence-aware parser:

```lua
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
```

- [ ] **Step 3: Add the public idempotent setup function**

```lua
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
```

- [ ] **Step 4: Run the focused test and verify GREEN**

Run:

```bash
nvim --clean --headless -u NONE -l tests/noice-markdown-fences_spec.lua
```

Expected: exit code 0 and `noice-markdown-fences: ok`.

- [ ] **Step 5: Format and re-run**

Run:

```bash
/home/dredd/.local/share/nvim/mason/bin/stylua \
  lua/noice-markdown-fences.lua \
  tests/noice-markdown-fences_spec.lua
nvim --clean --headless -u NONE -l tests/noice-markdown-fences_spec.lua
```

Expected: both commands exit 0.

### Task 3: Activate and Integrate the Shim

**Files:**

- Modify: `lua/config.lua:480-498`
- Verify: `lua/noice-markdown-fences.lua`
- Verify: `lua/treesitter-highlight-links.lua`
- Test: `tests/noice-markdown-fences_spec.lua`
- Test: `tests/treesitter-highlight-links_spec.lua`

**Interfaces:**

- Consumes: `require("noice-markdown-fences").setup()`.
- Produces: corrected Noice Markdown parsing for hover, completion
  documentation, and Noice's LSP Markdown stylizer.

- [ ] **Step 1: Activate the shim after Noice setup**

Immediately after the existing `require("noice").setup({ ... })` block, add:

```lua
require('noice-markdown-fences').setup()
```

- [ ] **Step 2: Verify the captured payload through the loaded config**

Create `/tmp/verify-noice-kotlin-fence.lua`:

```lua
local declaration = 'class String : Comparable<String>, CharSequence, java.io.Serializable'
local payload = table.concat({
  '````kotlin',
  declaration,
  '````',
}, '\n')

local blocks = require('noice.text.markdown').parse(payload)
assert(blocks[1].lang == 'kotlin')
assert(blocks[1].code[1] == declaration)
print('Noice Kotlin fence language: ' .. blocks[1].lang)
```

Run it with:

```bash
XDG_STATE_HOME=/tmp/nvim-doc-highlight-state \
nvim --headless -u /home/dredd/.config/nvim/init.lua \
  '+luafile /tmp/verify-noice-kotlin-fence.lua' \
  +qa
```

Expected: exit code 0 and `Noice Kotlin fence language: kotlin`.

- [ ] **Step 3: Verify Noice creates Kotlin syntax extmarks**

Extend `/tmp/verify-noice-kotlin-fence.lua` with:

```lua
local bufnr = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { declaration })

local ns = vim.api.nvim_create_namespace('NoiceKotlinFenceVerification')
require('noice.text.treesitter').highlight(bufnr, ns, { 0, 0, 1, 0 }, blocks[1].lang)

local groups = {}
for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })) do
  groups[mark[4].hl_group] = true
end

assert(groups['@keyword.type.kotlin'], 'missing Kotlin class keyword highlight')
assert(groups['@type.kotlin'], 'missing Kotlin type highlight')
print('Noice Kotlin syntax extmarks: keyword.type + type')
```

Expected: at least the `class` keyword and `String` type have distinct
Tree-sitter extmarks.

- [ ] **Step 4: Run all scoped automated checks**

Run:

```bash
nvim --clean --headless -u NONE -l tests/noice-markdown-fences_spec.lua
nvim --clean --headless -u NONE -l tests/treesitter-highlight-links_spec.lua
/home/dredd/.local/share/nvim/mason/bin/stylua --check \
  lua/noice-markdown-fences.lua \
  tests/noice-markdown-fences_spec.lua
git diff --check
```

Expected: every command exits 0.

- [ ] **Step 5: Review scope and index state**

Run:

```bash
git diff -- lua/config.lua lua/tree-sitter.lua
sed -n '1,280p' lua/noice-markdown-fences.lua
sed -n '1,360p' tests/noice-markdown-fences_spec.lua
git status --short
git diff --cached --name-only
```

Confirm the managed Noice plugin and `lua/nvim-tree-config.lua` were not
changed by this implementation, and the index is empty.

- [ ] **Step 6: Interactive smoke test**

Restart Neovim and verify:

1. `K` on Kotlin `String` gives distinct colors to `class`, `String`, and the
   implemented interfaces.
2. A Kotlin `nvim-cmp` documentation popup highlights fenced declaration code.
3. Ordinary explanatory prose remains normal Markdown text.

Leave all files unstaged and uncommitted.
