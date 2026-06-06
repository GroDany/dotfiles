-- WhichKey
require('which-key').setup()

-- Gitsigns
require('gitsigns').setup()

-- Oil (File Manager)
require("oil").setup({
    skip_confirm_for_simple_edits = true,
})
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch [G]rep' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find buffers' })-- Enable Mini Surround

require('mini.surround').setup({
    -- We set 'add' to something safe in Normal mode (like 'sa')
    -- so we can manually map 'S' in Visual mode below.
    mappings = {
        add = 'sa', -- Add surrounding in Normal mode
        delete = 'ds', -- Delete surrounding
        replace = 'cs', -- Change surrounding
        find = '', -- Disable find to keep it clean
        find_left = '',
        highlight = '',
        update_n_lines = '',
        suffix_last = '',
        suffix_next = '',
    },
})

-- Map 'S' in Visual Mode to Surround
-- This allows you to select text, press S, then ( or [ or {
vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true, desc = "Surround Selection" })
