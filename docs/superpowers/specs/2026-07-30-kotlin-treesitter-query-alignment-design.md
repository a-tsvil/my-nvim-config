# Kotlin Tree-sitter Query Alignment Design

## Goal

Restore stable Kotlin highlighting in normal buffers and Noice documentation
popups without query errors or popup flicker.

## Root cause

The installed Kotlin parser and nvim-treesitter query are version-aligned at
revision `c8ac3d2627240160b999a2c100de3babbdb8f419`. The installed query
compiles successfully against that parser.

The config also contains a full tracked override at
`queries/kotlin/highlights.scm`, copied from an older nvim-treesitter revision.
It references the obsolete anonymous node `$` at line 377. The current parser
does not expose that node, so compiling the override produces the exact error
shown interactively:

```text
Query error at 377:3. Invalid node type "$"
```

When Noice reaches Kotlin Tree-sitter highlighting, the uncaught query error
interrupts rendering, which accounts for the flickering and disappearing
popup. The same invalid query prevents the regular Kotlin buffer highlighter
from starting.

## Design

Delete only `queries/kotlin/highlights.scm`. Neovim will then use the Kotlin
highlight query installed and updated alongside nvim-treesitter.

Keep both config extensions under `after/queries/kotlin/`:

- `highlights.scm` adds the named-argument property capture.
- `injections.scm` retains the existing KDoc Markdown injection behavior.

Keep the current Kotlin parser configuration and installed parser unchanged.
The parser's current revision matches nvim-treesitter, so no parser download,
rebuild, or update is required.

## Verification

A headless integration test will:

1. Confirm the old tracked query fails before deletion.
2. Confirm `vim.treesitter.query.get("kotlin", "highlights")` succeeds after
   deletion and includes the `after/queries` extension.
3. Parse and highlight representative Kotlin containing a class declaration,
   types, and string interpolation.
4. Confirm regular-buffer Tree-sitter extmarks include Kotlin keyword, type,
   and string-related captures.
5. Re-run the captured four-backtick Noice payload check and confirm Kotlin
   keyword and type extmarks.
6. Re-run both existing documentation-highlighting regression tests.

## Scope and safety

No managed plugin files, parser binaries, LSP settings, completion settings,
Noice routing, colorscheme configuration, or `nvim-tree` files will change.
The tracked query deletion remains recoverable from Git and will be left
unstaged and uncommitted.
