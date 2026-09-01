local M = {}

function M.apply(language)
  local ok, query = pcall(vim.treesitter.query.get, language, 'highlights')
  if not ok or not query then
    return
  end

  local seen = {}
  for _, capture in ipairs(query.captures) do
    if not capture:match('^_') and not seen[capture] then
      seen[capture] = true

      local generic_group = '@' .. capture
      local language_group = ('%s.%s'):format(generic_group, language)
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
