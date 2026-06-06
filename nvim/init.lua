require("config.options")
require("config.keymaps")

-- Load the native package manager manifest
require("pack")

vim.g.clipboard = {
  name = 'win32yank-wsl',
  copy = {
     ["+"] = 'win32yank.exe -i --crlf',
     ["*"] = 'win32yank.exe -i --crlf',
   },
  paste = {
     ["+"] = 'win32yank.exe -o --lf',
     ["*"] = 'win32yank.exe -o --lf',
  },
  cache_enabled = 0,
}

vim.cmd([[
  if &ft != '' | filetype detect | endif
]])
