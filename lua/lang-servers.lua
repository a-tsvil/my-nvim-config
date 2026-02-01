vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          '${3rd}/luv/library',
          '${3rd}/busted/library',
        },
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
        -- library = vim.api.nvim_get_runtime_file("", true)
      },
    })
  end,
  settings = {
    Lua = {
      completion = {
        callSnippet = 'Replace',
      },
    },
  },
})
vim.lsp.enable('lua_ls')

vim.lsp.config('golangci_lint_ls', {
  init_options = {
    command = { 'golangci-lint', 'run', '--out-format=json', '--show-stats=false' },
    debounce = 1000,
  },
})
-- vim.lsp.enable('golangci_lint_ls')

vim.lsp.config('gopls', {
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
})
-- vim.lsp.enable('gopls')

-- vim.lsp.enable('terraformls')

vim.lsp.enable('eslint')

vim.lsp.config('ts_ls', {
  on_attach = function(client, bufnr)
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true)
    end
  end,
  settings = {
    completions = {
      completeFunctionCalls = true,
    },
    typescript = {
      completions = {
        completeFunctionCalls = true,
      },
      -- inlayHints = {
      --   includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
      --   includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      --   includeInlayVariableTypeHints = false,
      --   includeInlayFunctionParameterTypeHints = false,
      --   includeInlayVariableTypeHintsWhenTypeMatchesName = false,
      --   includeInlayPropertyDeclarationTypeHints = true,
      --   includeInlayFunctionLikeReturnTypeHints = true,
      --   includeInlayEnumMemberValueHints = true,
      -- },
    },
    javascript = {
      completions = {
        completeFunctionCalls = true,
      },
      -- inlayHints = {
      --   includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
      --   includeInlayParameterNameHintsWhenArgumentMatchesName = true,
      --   includeInlayVariableTypeHints = false,
      --   includeInlayFunctionParameterTypeHints = true,
      --   includeInlayVariableTypeHintsWhenTypeMatchesName = true,
      --   includeInlayPropertyDeclarationTypeHints = true,
      --   includeInlayFunctionLikeReturnTypeHints = true,
      --   includeInlayEnumMemberValueHints = true,
      -- },
    },
  },
})
vim.lsp.enable('ts_ls')

local angularls_path = '/home/atsvil/fraud-zero/admin-frontend/'

local cmd = {
  'ngserver',
  '--stdio',
  '--tsProbeLocations',
  table.concat({
    angularls_path,
    vim.uv.cwd(),
  }, ','),
  '--ngProbeLocations',
  table.concat({
    angularls_path .. '/node_modules/@angular/language-server',
    vim.uv.cwd(),
  }, ','),
}

vim.lsp.config('angularls', {
  cmd = cmd,
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = cmd
  end,
})
-- vim.lsp.enable('angularls')

-- vim.lsp.enable('phpactor')

-- vim.lsp.config('rust_analyzer', {
--   settings = {
--     ['rust-analyzer'] = {
--       cargo = {
--         allFeatures = true,
--       },
--       checkOnSave = {
--         command = 'clippy',
--       },
--     },
--   },
--   -- on_attach = function(client, bufnr)
--   --   -- Optional: key mappings for LSP
--   --   local bufopts = { noremap = true, silent = true, buffer = bufnr }
--   --   vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
--   --   vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
--   --   vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
--   -- end,
--   capabilities = require('cmp_nvim_lsp').default_capabilities(),
-- })
-- vim.lsp.enable('rust_analyzer')

vim.lsp.enable('sqls')
-- lspconfig.gleam.setup{}

-- vim.lsp.enable('prismals')

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('cssls', {
  capabilities = capabilities,
})
vim.lsp.enable('cssls')

-- various lsp related keymaps
vim.keymap.set('n', '<Leader>lr', vim.lsp.buf.rename)

vim.lsp.config('pyright', {
  before_init = function(_, config)
    local venv_path = os.getenv('VIRTUAL_ENV')
    if venv_path then
      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = venv_path .. '/bin/python'
    end
  end,
})
-- vim.lsp.enable('pyright')

vim.lsp.config('jsonls', {
  capabilities = capabilities,
})
vim.lsp.enable('jsonls')

-- vim.lsp.enable('tailwindcss')
--
local util = require('lspconfig.util')

-- vim.lsp.config('kotlin_lsp', {
--   cmd = { 'kotlin-lsp', '--stdio' },
--   filetypes = { 'kotlin' },

--   root_dir = function(fname)
--     return util.root_pattern('settings.gradle.kts', 'settings.gradle', 'build.gradle.kts', 'build.gradle')(fname)
--       or util.root_pattern('.git')(fname)
--       or util.path.dirname(fname)
--   end,
-- })
vim.lsp.enable('kotlin_lsp')

vim.lsp.enable('vacuum')

vim.lsp.enable('biome')

require('tiny-code-action').setup({
  picker = {
    'buffer',
    opts = {
      hotkeys = true, -- Enable hotkeys for quick selection of actions
      hotkeys_mode = 'text_diff_based', -- Modes for generating hotkeys
      auto_preview = false, -- Enable or disable automatic preview
      auto_accept = false, -- Automatically accept the selected action (with hotkeys)
      position = 'cursor', -- Position of the picker window
      winborder = 'single', -- Border style for picker and preview windows
      keymaps = {
        preview = 'K', -- Key to show preview
        close = { 'q', '<Esc>' }, -- Keys to close the window (can be string or table)
        select = '<CR>', -- Keys to select action (can be string or table)
      },
      custom_keys = {
        { key = 'm', pattern = 'Fill match arms' },
        { key = 'r', pattern = 'Rename.*' }, -- Lua pattern matching
      },
    },
  },
})

vim.keymap.set({ 'n', 'x' }, '<leader>ca', function()
  require('tiny-code-action').code_action()
end, { noremap = true, silent = true })

-- vim.keymap.set('n', '<leader>ca', function()
--   vim.lsp.buf.code_action()
-- end, { desc = 'Open available code actions' })

vim.lsp.enable('marksman')

-- Show full type / interface / alias of symbol under cursor in a float
local function show_full_type()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify('No LSP client attached', vim.log.levels.WARN)
    return
  end

  local client = clients[1]
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

  vim.lsp.buf_request(bufnr, 'textDocument/typeDefinition', params, function(err, result)
    if err then
      vim.notify('LSP error: ' .. err.message, vim.log.levels.ERROR)
      return
    end
    if not result or vim.tbl_isempty(result) then
      vim.notify('No type definition found', vim.log.levels.INFO)
      return
    end

    local loc = result[1]
    local uri = loc.uri or loc.targetUri
    local def_buf = vim.uri_to_bufnr(uri)
    vim.fn.bufload(def_buf)

    -- tsserver can return different shapes (Location / LocationLink)
    local range = loc.range or loc.targetRange or loc.targetSelectionRange
    if not range then
      vim.notify('No range in type definition result', vim.log.levels.WARN)
      return
    end

    local start_line = range.start.line

    -- read from the definition line to the end of file
    local lines = vim.api.nvim_buf_get_lines(def_buf, start_line, -1, false)
    if not lines or #lines == 0 then
      vim.notify('Could not read type definition lines', vim.log.levels.WARN)
      return
    end

    local extracted = {}
    local brace_depth = 0
    local seen_braces = false

    for i, line in ipairs(lines) do
      table.insert(extracted, line)

      -- count braces on this line
      local opens = select(2, line:gsub('{', ''))
      local closes = select(2, line:gsub('}', ''))
      if opens > 0 or closes > 0 then
        seen_braces = true
      end
      brace_depth = brace_depth + opens - closes

      local trimmed = vim.trim(line)

      -- case 1: alias without braces, ended by semicolon
      if not seen_braces and trimmed:match(';$') then
        break
      end

      -- case 2: block type (interface / type / class / whatever) ended when braces balanced again
      if seen_braces and brace_depth == 0 then
        break
      end

      -- safety guard so we don't dump entire file if something goes weird
      if i > 120 then
        break
      end
    end

    vim.lsp.util.open_floating_preview(extracted, vim.bo.filetype, {
      border = 'rounded',
      max_width = 100,
    })
  end)
end

vim.keymap.set('n', '<leader>ti', show_full_type, {
  desc = 'Show full internal type definition',
})

vim.lsp.enable('bashls')
