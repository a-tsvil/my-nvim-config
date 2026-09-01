# Kotlin LSP Documentation Highlighting Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Kotlin code and comments syntax-highlight correctly inside both LSP hover and `nvim-cmp` documentation popups rendered by Noice.

**Architecture:** Add a small Tree-sitter highlight-link helper that reads a language's installed `highlights` query and creates missing language-specific groups as links to their generic captures. Call it for Kotlin from the existing centralized Tree-sitter setup at startup and after every `ColorScheme` event.

**Tech Stack:** Neovim 0.12 Lua API, Tree-sitter highlight queries, Noice Markdown rendering, a headless Neovim regression script.

## Global Constraints

- Do not stage or commit any files.
- Preserve the user's existing changes in `lua/nvim-tree-config.lua`.
- Do not modify LSP, Noice, completion, colorscheme, or `nvim-tree` configuration.
- Do not install or update plugins, parsers, or external dependencies.

## File Map

- Create: `lua/treesitter-highlight-links.lua`
  - Owns guarded query loading and missing language-specific highlight links.
- Create: `tests/treesitter-highlight-links_spec.lua`
  - Exercises query failure, private-capture filtering, fallback creation, preservation of explicit styles, deduplication, and reapplication.
- Modify: `lua/tree-sitter.lua:114-122`
  - Applies Kotlin fallback links at startup and through the existing `ColorScheme` callback.
- Reference only: `docs/superpowers/specs/2026-07-30-kotlin-lsp-doc-highlighting-design.md`
  - Approved behavior and scope.

---

### Task 1: Specify the Highlight-Link Helper

**Files:**

- Create: `tests/treesitter-highlight-links_spec.lua`
- Test: `tests/treesitter-highlight-links_spec.lua`

- [ ] **Step 1: Add a minimal headless test harness**

Create `tests/treesitter-highlight-links_spec.lua` with a local assertion helper and add this repository to `runtimepath`:

```lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local function assert_equal(actual, expected, message)
  if not vim.deep_equal(actual, expected) then
    error(("%s\nexpected: %s\nactual: %s"):format(
      message,
      vim.inspect(expected),
      vim.inspect(actual)
    ))
  end
end
```

- [ ] **Step 2: Write failing behavior tests**

Stub `vim.treesitter.query.get` with a query containing public, private, dotted, and duplicate capture names:

```lua
local original_query_get = vim.treesitter.query.get

vim.treesitter.query.get = function(language, query_name)
  assert_equal(language, "kotlin", "uses the requested language")
  assert_equal(query_name, "highlights", "loads the highlights query")
  return {
    captures = {
      "keyword",
      "type.builtin",
      "_private",
      "keyword",
    },
  }
end

vim.api.nvim_set_hl(0, "@keyword.kotlin", {})
vim.api.nvim_set_hl(0, "@type.builtin.kotlin", { fg = 0x123456 })
vim.api.nvim_set_hl(0, "@_private.kotlin", {})

local links = require("treesitter-highlight-links")
links.apply("kotlin")

assert_equal(
  vim.api.nvim_get_hl(0, { name = "@keyword.kotlin", link = true }).link,
  "@keyword",
  "creates a fallback for a missing public capture"
)
assert_equal(
  vim.api.nvim_get_hl(0, { name = "@type.builtin.kotlin", link = true }).fg,
  0x123456,
  "preserves an explicit language-specific style"
)
assert_equal(
  vim.api.nvim_get_hl(0, { name = "@_private.kotlin", link = true }),
  {},
  "ignores private captures"
)
```

Then clear `@keyword.kotlin`, call `links.apply("kotlin")` again, and assert that the fallback link is restored. Finally, replace the query stub with a function that raises an error and assert that `links.apply("kotlin")` itself does not raise. Restore `vim.treesitter.query.get` even when an assertion fails by wrapping the test body in `xpcall`.

- [ ] **Step 3: Run the test and confirm the expected failure**

Run:

```bash
nvim --clean --headless -u NONE -l tests/treesitter-highlight-links_spec.lua
```

Expected: non-zero exit because `treesitter-highlight-links` does not exist yet.

### Task 2: Implement the Highlight-Link Helper

**Files:**

- Create: `lua/treesitter-highlight-links.lua`
- Test: `tests/treesitter-highlight-links_spec.lua`

- [ ] **Step 1: Implement guarded query loading**

Create `lua/treesitter-highlight-links.lua`:

```lua
local M = {}

function M.apply(language)
  local ok, query = pcall(vim.treesitter.query.get, language, "highlights")
  if not ok or not query then
    return
  end

  local seen = {}
  for _, capture in ipairs(query.captures) do
    if not capture:match("^_") and not seen[capture] then
      seen[capture] = true

      local generic_group = "@" .. capture
      local language_group = ("%s.%s"):format(generic_group, language)
      local existing = vim.api.nvim_get_hl(0, {
        name = language_group,
        link = true,
      })

      if vim.tbl_isempty(existing) then
        vim.api.nvim_set_hl(0, language_group, {
          link = generic_group,
        })
      end
    end
  end
end

return M
```

- [ ] **Step 2: Run the focused test**

Run:

```bash
nvim --clean --headless -u NONE -l tests/treesitter-highlight-links_spec.lua
```

Expected: exit code 0 with no assertion errors.

- [ ] **Step 3: Format and re-run the focused test**

Run:

```bash
stylua lua/treesitter-highlight-links.lua tests/treesitter-highlight-links_spec.lua
nvim --clean --headless -u NONE -l tests/treesitter-highlight-links_spec.lua
```

Expected: formatting succeeds and the test remains green.

### Task 3: Wire Kotlin Fallbacks into the Existing Tree-sitter Setup

**Files:**

- Modify: `lua/tree-sitter.lua:114-122`
- Test: `tests/treesitter-highlight-links_spec.lua`

- [ ] **Step 1: Add the Kotlin application call**

Update the existing highlight callback:

```lua
local treesitter_highlight_links = require("treesitter-highlight-links")

local function apply_treesitter_links()
  vim.api.nvim_set_hl(0, "@property", { link = "@variable.member" })
  treesitter_highlight_links.apply("kotlin")
end
```

Keep the existing startup call and `ColorScheme` autocommand unchanged so both paths invoke the expanded callback.

- [ ] **Step 2: Verify every installed Kotlin public capture resolves**

Run a headless Neovim check with the real config but a temporary state path so
normal logs and ShaDa are untouched:

```bash
XDG_STATE_HOME=/tmp/nvim-doc-highlight-state \
nvim --headless -u /home/dredd/.config/nvim/init.lua \
  "+lua local q=assert(vim.treesitter.query.get('kotlin','highlights')); for _,c in ipairs(q.captures) do if not c:match('^_') then assert(not vim.tbl_isempty(vim.api.nvim_get_hl(0,{name=('@%s.kotlin'):format(c),link=true})), c) end end" \
  +qa
```

Expected: exit code 0 and no missing capture name. The known headless
`nvim-tree` `FileExplorer` warning may still be printed; it is unrelated to
this assertion and must not be addressed in this change.

- [ ] **Step 3: Verify the `ColorScheme` path restores a removed fallback**

Run:

```bash
XDG_STATE_HOME=/tmp/nvim-doc-highlight-state \
nvim --headless -u /home/dredd/.config/nvim/init.lua \
  "+lua vim.api.nvim_set_hl(0,'@keyword.kotlin',{}); vim.api.nvim_exec_autocmds('ColorScheme',{}); assert(vim.api.nvim_get_hl(0,{name='@keyword.kotlin',link=true}).link == '@keyword')" \
  +qa
```

Expected: exit code 0.

- [ ] **Step 4: Re-run the isolated regression test**

Run:

```bash
nvim --clean --headless -u NONE -l tests/treesitter-highlight-links_spec.lua
```

Expected: exit code 0.

### Task 4: Final Verification and User Smoke Test

**Files:**

- Verify: `lua/treesitter-highlight-links.lua`
- Verify: `lua/tree-sitter.lua`
- Verify: `tests/treesitter-highlight-links_spec.lua`

- [ ] **Step 1: Review the exact working-tree diff**

Run:

```bash
git diff -- lua/tree-sitter.lua
sed -n '1,240p' lua/treesitter-highlight-links.lua
sed -n '1,320p' tests/treesitter-highlight-links_spec.lua
git status --short
```

Confirm that:

- only the intended Tree-sitter files and test were changed by this implementation;
- `lua/nvim-tree-config.lua` remains untouched by this work;
- nothing is staged;
- no LSP, Noice, completion, or colorscheme settings changed.

- [ ] **Step 2: Run Lua formatting validation**

Run:

```bash
stylua --check lua/tree-sitter.lua lua/treesitter-highlight-links.lua tests/treesitter-highlight-links_spec.lua
```

Expected: exit code 0.

- [ ] **Step 3: Run all automated checks once more**

Run the focused test and both headless integration commands from Tasks 2 and 3. Record their exit codes and any output.

- [ ] **Step 4: Perform the interactive popup smoke test**

Restart Neovim, open a Kotlin file, and verify:

1. Put the cursor on `String` or another documented Kotlin/JDK symbol and press `K`.
2. Confirm Kotlin fenced code in the hover popup has distinct highlighting for keywords, types, strings, and comments.
3. Trigger completion for a Kotlin symbol with documentation and open the `nvim-cmp` documentation window.
4. Confirm the same classes of Kotlin syntax are highlighted there.

If either popup still lacks highlighting, inspect its actual fenced-code language and capture groups before broadening the implementation.

- [ ] **Step 5: Report completion without committing**

Summarize the files changed, automated verification results, and the user's smoke-test result. Leave every change uncommitted and unstaged.
