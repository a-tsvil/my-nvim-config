local config_root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(config_root)
package.path = ('%s/lua/?.lua;%s'):format(config_root, package.path)

local function assert_equal(actual, expected, message)
  if not vim.deep_equal(actual, expected) then
    error(('%s\nexpected: %s\nactual: %s'):format(message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local original_query_get = vim.treesitter.query.get

local ok, err = xpcall(function()
  vim.treesitter.query.get = function(language, query_name)
    assert_equal(language, 'kotlin', 'uses the requested language')
    assert_equal(query_name, 'highlights', 'loads the highlights query')

    return {
      captures = {
        'keyword',
        'type.builtin',
        '_private',
        'keyword',
      },
    }
  end

  vim.api.nvim_set_hl(0, '@keyword.kotlin', {})
  vim.api.nvim_set_hl(0, '@type.builtin.kotlin', { fg = 0x123456 })
  vim.api.nvim_set_hl(0, '@_private.kotlin', {})

  local links = require('treesitter-highlight-links')
  links.apply('kotlin')

  assert_equal(
    vim.api.nvim_get_hl(0, { name = '@keyword.kotlin', link = true }).link,
    '@keyword',
    'creates a fallback for a missing public capture'
  )
  assert_equal(
    vim.api.nvim_get_hl(0, { name = '@type.builtin.kotlin', link = true }).fg,
    0x123456,
    'preserves an explicit language-specific style'
  )
  assert_equal(vim.api.nvim_get_hl(0, { name = '@_private.kotlin', link = true }), {}, 'ignores private captures')

  vim.api.nvim_set_hl(0, '@keyword.kotlin', {})
  links.apply('kotlin')
  assert_equal(
    vim.api.nvim_get_hl(0, { name = '@keyword.kotlin', link = true }).link,
    '@keyword',
    'restores a missing fallback when reapplied'
  )

  vim.treesitter.query.get = function()
    error('query unavailable')
  end
  assert_equal(pcall(links.apply, 'kotlin'), true, 'ignores query-loading failures')
end, debug.traceback)

vim.treesitter.query.get = original_query_get

if not ok then
  error(err)
end

print('treesitter-highlight-links: ok')
