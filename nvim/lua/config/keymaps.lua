vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map('v', 'J', ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = "Move line up" })

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<leader>gs', vim.cmd.Gdiffsplit, { desc = "Git Diff Split" })
-- map('n', '<leader>pv', vim.cmd.Ex, { desc = "Open NetRW/Ex" })

map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic List' })
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous Diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show Error' })

map("v", "p", [["_dP]], { noremap = true, silent = true, desc = "Paste without overwriting register" })

map('n', '<leader>cc', '<cmd>let @+ = expand("%:t")<CR>', { desc = "Copy filename" })

