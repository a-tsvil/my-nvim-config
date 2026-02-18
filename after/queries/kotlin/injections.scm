; extends
; TODO(future): Re-enable KDoc markdown injection once behavior is stable
; with current Kotlin parser + LSP setup.

((multiline_comment) @injection.content
 (#lua-match? @injection.content "^/%*%*")
 (#set! injection.language "markdown"))
