-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'lua_ls', 'rust_analyzer', 'gopls', 'ts_ls', 'phpactor' }
for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  })
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  preselect = cmp.PreselectMode.None,
  completion = {
    completeopt = 'menu,menuone,noinsert,noselect',
  },
  window = {
    completion = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if not cmp.get_selected_entry() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        end
        cmp.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-y>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if not cmp.get_selected_entry() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        end
        cmp.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = false,
        })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'nvim_lsp_signature_help' },
  },
}

-- Kotlin-only completion tuning.
-- Disable with: vim.g.kotlin_cmp_tuned = false (set before this module loads).
if vim.g.kotlin_cmp_tuned ~= false then
  cmp.setup.filetype('kotlin', {
    performance = {
      -- Keep Kotlin LSP stable under heavy typing/load.
      debounce = 60,
      throttle = 80,
      fetching_timeout = 350,
      max_view_entries = 20,
    },
    completion = {
      -- Keep manual completion stable when typing from an empty cursor position.
      keyword_length = 1,
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp', max_item_count = 30 },
      { name = 'luasnip', max_item_count = 8 },
    }),
  })
end
