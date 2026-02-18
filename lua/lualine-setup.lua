local lsp_ft_enabled_cache = {}
local lsp_expected_filetypes_fallback = {
  lua = true,
  kotlin = true,
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  json = true,
  css = true,
  scss = true,
  markdown = true,
  sql = true,
  go = true,
}

local function has_enabled_lsp_for_filetype(ft)
  if not ft or ft == '' then
    return false
  end
  if lsp_ft_enabled_cache[ft] ~= nil then
    return lsp_ft_enabled_cache[ft]
  end

  if not vim.lsp.get_configs then
    lsp_ft_enabled_cache[ft] = lsp_expected_filetypes_fallback[ft] == true
    return lsp_ft_enabled_cache[ft]
  end

  local ok, configs = pcall(vim.lsp.get_configs)
  if not ok or type(configs) ~= 'table' then
    lsp_ft_enabled_cache[ft] = false
    return false
  end

  for name, cfg in pairs(configs) do
    local enabled = true
    if vim.lsp.is_enabled then
      local ok_enabled, value = pcall(vim.lsp.is_enabled, name)
      enabled = ok_enabled and value or false
    end
    if enabled then
      local fts = cfg.filetypes
      if fts == nil or vim.list_contains(fts, ft) then
        lsp_ft_enabled_cache[ft] = true
        return true
      end
    end
  end

  lsp_ft_enabled_cache[ft] = false
  return false
end

local function lsp_loader_frame()
  local frames = { '-', '\\', '|', '/' }
  local idx = (math.floor(vim.uv.hrtime() / 1e8) % #frames) + 1
  return frames[idx]
end

local function lsp_clients_component()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local active = {}
  local initializing = false

  for _, client in ipairs(clients or {}) do
    local stopped = false
    if type(client.is_stopped) == 'function' then
      stopped = client:is_stopped()
    elseif client.stopped ~= nil then
      stopped = client.stopped
    end

    if not stopped then
      active[#active + 1] = client
      if client.initialized == false then
        initializing = true
      end
    end
  end

  if #active == 0 then
    if vim.bo[bufnr].buftype ~= '' then
      return ''
    end
    local ft = vim.bo[bufnr].filetype
    if has_enabled_lsp_for_filetype(ft) then
      return 'LSP~' .. lsp_loader_frame()
    end
    return ''
  end

  if initializing then
    return 'LSP~' .. lsp_loader_frame()
  end

  local names = {}
  for _, client in ipairs(active) do
    if client.name then
      names[#names + 1] = client.name
    end
  end
  table.sort(names)

  return 'LSP:' .. table.concat(names, ',')
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { lsp_clients_component, 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
}

local lualine_lsp_refresh_group = vim.api.nvim_create_augroup('ConfigLualineLspRefresh', { clear = true })
vim.api.nvim_create_autocmd({ 'LspAttach', 'LspDetach' }, {
  group = lualine_lsp_refresh_group,
  callback = function()
    pcall(require('lualine').refresh, { place = { 'statusline' } })
  end,
})
