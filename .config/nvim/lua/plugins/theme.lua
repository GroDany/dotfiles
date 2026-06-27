local statusline = require('mini.statusline')

require('gruber-darker').setup()
vim.cmd.colorscheme('gruber-darker')

require('todo-comments').setup({ signs = false })

-- Statusline setup
statusline.setup({ use_icons = vim.g.have_nerd_font })
