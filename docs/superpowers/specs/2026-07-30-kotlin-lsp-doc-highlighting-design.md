# Kotlin LSP Documentation Highlighting Design

## Goal

Show Kotlin syntax highlighting inside both LSP hover documentation and
`nvim-cmp` documentation popups while retaining Noice as their Markdown
renderer.

## Current behavior

Noice parses fenced Kotlin blocks and assigns language-specific Tree-sitter
highlight groups such as `@keyword.kotlin` and `@type.kotlin`. The active
colorscheme defines the generic groups (`@keyword`, `@type`, and others), but
none of the 43 Kotlin-specific groups used by the installed Kotlin highlight
query. Consequently, Noice creates highlight extmarks whose groups have no
visible style.

The Markdown, Markdown-inline, and Kotlin parsers are installed. Noice is
running interactively, and its LSP and completion documentation overrides are
enabled. Neither component needs to be replaced.

## Design

Extend the centralized Tree-sitter highlight setup in `lua/tree-sitter.lua`.
Read the installed Kotlin `highlights` query and, for every public capture,
create a language-specific fallback:

```text
@<capture>.kotlin -> @<capture>
```

Create a fallback only when the language-specific group has no existing
definition. This preserves deliberate Kotlin-specific styling supplied by a
colorscheme or user configuration.

Apply the links once during startup and again from the existing `ColorScheme`
autocommand so changing themes cannot remove the fallbacks.

## Error handling

Query loading must be protected so Neovim still starts if the Kotlin parser or
highlight query is temporarily unavailable during installation or updates.
Private captures whose names begin with `_` are ignored.

## Verification

Automated checks will confirm:

1. Neovim starts without a Lua error.
2. Every public capture in the Kotlin highlight query has either an explicit
   language-specific definition or a fallback link.
3. Existing explicit Kotlin-specific definitions are not overwritten.
4. Reapplying the setup after a simulated colorscheme change restores missing
   fallback links.

Manual smoke checks will confirm that Kotlin code and comments are highlighted
in both the `K` hover popup and the `nvim-cmp` documentation popup.

## Scope

This change affects only Kotlin Tree-sitter highlight-group resolution. It does
not change LSP capabilities, Noice routing, completion behavior, colorscheme
selection, or `nvim-tree`.
