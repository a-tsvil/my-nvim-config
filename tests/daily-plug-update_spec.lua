-- Run: nvim --headless -u NONE -i NONE -l tests/daily-plug-update_spec.lua
local callback
local today = '2026-10-25'
local recorded
local interactive = true
local updates = 0
local noop = function() end
local mock = {
  fn = setmetatable({
    expand = function(path) return path end,
    stdpath = function(kind)
      assert(kind == 'state')
      return '/test-state'
    end,
    strftime = function() return today end,
    filereadable = function() return recorded and 1 or 0 end,
    readfile = function() return { recorded } end,
    writefile = function(lines, path)
      assert(path == '/test-state/plug-update-date')
      recorded = lines[1]
    end,
  }, { __index = function() return noop end }),
  api = {
    nvim_create_augroup = noop,
    nvim_create_autocmd = function(event, opts)
      assert(event == 'VimEnter')
      callback = opts.callback
    end,
    nvim_list_uis = function() return interactive and { {} } or {} end,
  },
  cmd = { PlugUpdate = function() updates = updates + 1 end },
}
local init = assert(loadfile('init.lua'))
setfenv(init, { vim = mock, require = noop })
init()

interactive = false
callback()
assert(updates == 0 and recorded == nil, 'headless startup must not update or record the date')
interactive = true
callback()
assert(updates == 1 and recorded == today, 'first interactive startup must update')
callback()
assert(updates == 1, 'another startup on the same day must skip updating')
today = '2026-10-26'
callback()
assert(updates == 2 and recorded == today, 'first startup on the next day must update')

print('daily-plug-update: ok')
