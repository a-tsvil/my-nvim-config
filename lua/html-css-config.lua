local ok, htmlcss = pcall(require, 'html-css')
if not ok then
  return
end

-- TEMP WORKAROUND (remove after upstream fix):
-- nvim-html-css currently returns a constant request id (1), which causes
-- Neovim 0.11+ to reject overlapping requests:
-- "Cannot create request with id 1 as one already exists".
-- A separate temporary context workaround lives in `lua/html-css/lsp.lua`.
-- See: HTML_CSS_LSP_REQUEST_ID_BUG.md
--
-- Disable this workaround by setting:
--   vim.g.html_css_lsp_workaround_enabled = false
-- before this file is loaded.
if vim.g.html_css_lsp_workaround_enabled ~= false and not vim.g.html_css_lsp_workaround_applied then
  local original_lsp_start = vim.lsp.start

  vim.lsp.start = function(config, opts)
    if type(config) == 'table' and config.name == 'html-css-lsp' and type(config.cmd) == 'function' then
      local original_cmd = config.cmd
      config.cmd = function(dispatchers)
        local server = original_cmd(dispatchers)

        if
          type(server) == 'table'
          and type(server.request) == 'function'
          and not server.__html_css_reqid_workaround
        then
          local original_request = server.request
          local next_request_id = 0

          server.request = function(method, params, callback)
            local ok_request = original_request(method, params, callback)
            if ok_request == false then
              return false
            end

            next_request_id = next_request_id + 1
            return true, next_request_id
          end

          server.__html_css_reqid_workaround = true
        end

        return server
      end
    end

    return original_lsp_start(config, opts)
  end

  vim.g.html_css_lsp_workaround_applied = true
end

-- Default plugin configuration; completion is provided through nvim-cmp's
-- `nvim_lsp` source (`cmp-nvim-lsp` installed).
htmlcss.setup({
  enable_on = {
    'html',
    'htmldjango',
    'tsx',
    'jsx',
    'erb',
    'svelte',
    'vue',
    'blade',
    'php',
    'templ',
    'astro',
  },
  handlers = {
    definition = {
      bind = 'gd',
    },
    hover = {
      bind = 'K',
      wrap = true,
      border = 'none',
      position = 'cursor',
    },
  },
  documentation = {
    auto_show = true,
  },
  style_sheets = {
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
    'https://uikit.developers.rio.cloud/2.1.0/rio-uikit.css',
    'https://uikit.developers.rio.cloud/2.1.0/rio-uikit-print-utilities.css',
  },
})
