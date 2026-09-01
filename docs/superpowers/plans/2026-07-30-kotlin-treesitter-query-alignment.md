# Kotlin Tree-sitter Query Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the stale Kotlin query override so normal buffers and Noice documentation use the query version installed with nvim-treesitter.

**Architecture:** Add a headless integration test that deliberately places the config before the installed Tree-sitter site on `runtimepath`, reproducing the interactive override failure. Delete the obsolete full query; retain and exercise the focused `after/queries/kotlin` extensions.

**Tech Stack:** Neovim 0.12 Tree-sitter Lua API, nvim-treesitter Kotlin parser/query, headless Neovim tests.

## Global Constraints

- Do not stage or commit any files.
- Delete only `queries/kotlin/highlights.scm`.
- Do not edit or update managed plugin files or installed parser binaries.
- Preserve both files under `after/queries/kotlin/`.
- Preserve the user's existing `lua/nvim-tree-config.lua` changes.

## File Map

- Create: `tests/kotlin-treesitter-query_spec.lua`
  - Reproduces query precedence and validates representative Kotlin captures.
- Delete: `queries/kotlin/highlights.scm`
  - Removes the obsolete full-query override.
- Verify: `after/queries/kotlin/highlights.scm`
  - Continues adding named-argument property captures.
- Verify: `after/queries/kotlin/injections.scm`
  - Remains unchanged.
- Verify: `tests/noice-markdown-fences_spec.lua`
- Verify: `tests/treesitter-highlight-links_spec.lua`

---

### Task 1: Reproduce the Stale Query Failure

**Files:**

- Create: `tests/kotlin-treesitter-query_spec.lua`
- Test: `tests/kotlin-treesitter-query_spec.lua`

**Interfaces:**

- Consumes: `vim.treesitter.query.get("kotlin", "highlights")` and the installed
  Kotlin parser under `stdpath("data") .. "/site"`.
- Produces: a regression test proving the selected query compiles and captures
  normal Kotlin syntax plus the config's named-argument extension.

- [ ] **Step 1: Add the isolated runtime-path fixture**

Create `tests/kotlin-treesitter-query_spec.lua`:

```lua
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
```

This order intentionally makes a config base query win over the installed
query, matching the failing interactive condition.

- [ ] **Step 2: Add the real query and capture assertions**

Append:

```lua
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
```

- [ ] **Step 3: Run the test and verify RED**

Run:

```bash
nvim --clean --headless -u NONE -l tests/kotlin-treesitter-query_spec.lua
```

Expected: non-zero exit with `Invalid node type "$"` from the tracked config
query at line 377.

### Task 2: Remove the Obsolete Base Query

**Files:**

- Delete: `queries/kotlin/highlights.scm`
- Test: `tests/kotlin-treesitter-query_spec.lua`

**Interfaces:**

- Consumes: nvim-treesitter's installed Kotlin base query.
- Produces: one valid base query plus the existing config `after` extensions.

- [ ] **Step 1: Delete the stale tracked query**

Delete:

```text
queries/kotlin/highlights.scm
```

Do not delete or edit either file under `after/queries/kotlin/`.

- [ ] **Step 2: Run the integration test and verify GREEN**

Run:

```bash
nvim --clean --headless -u NONE -l tests/kotlin-treesitter-query_spec.lua
```

Expected: exit code 0 and `kotlin-treesitter-query: ok`.

### Task 3: Verify Normal Buffers and Noice Documentation Together

**Files:**

- Verify: `tests/kotlin-treesitter-query_spec.lua`
- Verify: `tests/noice-markdown-fences_spec.lua`
- Verify: `tests/treesitter-highlight-links_spec.lua`
- Verify: `/tmp/verify-noice-kotlin-fence.lua`

**Interfaces:**

- Consumes: the installed Kotlin query, the remaining `after` extension, and
  the Noice fence compatibility shim.
- Produces: fresh evidence for normal-buffer and popup syntax highlighting.

- [ ] **Step 1: Run all three regression tests**

Run:

```bash
nvim --clean --headless -u NONE -l tests/kotlin-treesitter-query_spec.lua
nvim --clean --headless -u NONE -l tests/noice-markdown-fences_spec.lua
nvim --clean --headless -u NONE -l tests/treesitter-highlight-links_spec.lua
```

Expected: all three commands exit 0.

- [ ] **Step 2: Re-run the full-config Noice payload verification**

Run:

```bash
XDG_STATE_HOME=/tmp/nvim-doc-highlight-state \
nvim --headless -u /home/dredd/.config/nvim/init.lua \
  '+luafile /tmp/verify-noice-kotlin-fence.lua' \
  +qa
```

Expected:

```text
Noice Kotlin fence language: kotlin
Noice Kotlin syntax extmarks: keyword.type + type
```

- [ ] **Step 3: Check formatting, whitespace, and scope**

Run:

```bash
/home/dredd/.local/share/nvim/mason/bin/stylua --check \
  tests/kotlin-treesitter-query_spec.lua
git diff --check
git status --short
git diff --cached --name-only
git -C /home/dredd/.nvim/plugin/nvim-treesitter status --short
```

Confirm:

- `queries/kotlin/highlights.scm` is the only deleted file;
- both `after/queries/kotlin` files are unchanged;
- managed nvim-treesitter files were not changed by this task;
- the Git index remains empty.

- [ ] **Step 4: Interactive smoke test**

Fully restart Neovim, open a Kotlin file, and verify:

1. Normal Kotlin code is highlighted without a query notification.
2. `K` hover remains visible and syntax-highlighted without flickering.
3. Kotlin `nvim-cmp` documentation remains visible and syntax-highlighted.

Leave every change unstaged and uncommitted.
