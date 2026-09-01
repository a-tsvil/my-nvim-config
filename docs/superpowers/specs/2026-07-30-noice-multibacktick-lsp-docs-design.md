# Noice Multi-Backtick LSP Documentation Design

## Goal

Make Kotlin syntax highlighting run inside both LSP hover and `nvim-cmp`
documentation when Kotlin LSP wraps declarations in four-backtick Markdown
fences.

## Root cause

Kotlin LSP returns hover Markdown in this form:

```text
````kotlin
class String : Comparable<String>, CharSequence, java.io.Serializable
````
```

The installed Noice parser recognizes the line as a code fence but extracts
the language with a pattern that assumes exactly three backticks. It therefore
produces the language `` `kotlin `` instead of `kotlin`. Noice cannot load a
Tree-sitter parser for that invalid language name, so the code block receives
no Kotlin syntax highlights.

The installed highlight groups are not the remaining failure: generic and
Kotlin-specific groups for keywords, types, functions, and comments all
resolve to distinct visible styles. The upstream Noice project has an open
pull request for four-or-more-backtick fences, but the fix is not present in
the installed revision.

## Design

Add `lua/noice-markdown-fences.lua`, a small runtime compatibility module. Its
`setup()` function will:

1. Load `noice.text.markdown`.
2. Probe its parser with a four-backtick Kotlin block.
3. Return without changing anything if the parser already reports the
   language as `kotlin`.
4. Otherwise replace only the exported `parse` function with a fence-aware
   equivalent based on the installed parser.

The compatibility parser will retain the installed parser's current behavior
for blank lines, horizontal rules, Markdown prose, HTML entities, and
triple-backtick blocks. For code blocks it will:

- accept opening fences of three or more backticks;
- extract the language after the complete opening fence;
- close the block only on a backtick-only line whose fence is at least as long
  as the opening fence;
- keep shorter backtick sequences inside the code as code content.

Call `setup()` immediately after `require("noice").setup(...)` in
`lua/config.lua`. Noice's hover renderer, completion documentation override,
and Markdown stylizer all consume the exported parser dynamically, so this
single integration point covers both requested popups.

## Compatibility and error handling

The patch is runtime-only and does not modify files under the managed
`noice.nvim` plugin directory. A weak-key registry makes repeated `setup()`
calls idempotent without retaining obsolete module tables.

The feature probe makes the shim self-disabling: after a future Noice update
adds correct multi-backtick support, the local compatibility parser will not
be installed.

## Verification

An isolated headless regression test will first demonstrate the installed
Noice failure, then verify that the shim:

1. Parses the exact Kotlin LSP four-backtick payload as language `kotlin`.
2. Preserves the declaration as code.
3. Leaves ordinary triple-backtick behavior unchanged.
4. Keeps an inner triple-backtick line inside a four-backtick block.
5. Is idempotent.
6. Does not replace a parser that already supports four-backtick fences.

An integration check will render the captured Kotlin hover payload into a
buffer and confirm that Noice creates multiple Kotlin Tree-sitter highlight
groups, including keyword and type captures. The existing highlight-link
regression test will also remain green.

The final interactive smoke test is to restart Neovim and inspect both `K`
hover and `nvim-cmp` documentation in a Kotlin file.

## Scope

This change does not update or edit the Noice plugin, replace Noice, change
LSP capabilities, alter completion behavior, or touch `nvim-tree`. Ordinary
documentation prose will keep its normal Markdown styling; syntax colors apply
to fenced code blocks.
