local function ensure(repo)
    local name = repo:match("([^/]+)$"):gsub("%.git$", "")
    local install_path = vim.fn.stdpath("data") .. "/site/pack/my_plugins/start/" .. name

    if vim.fn.isdirectory(install_path) == 0 then
        print("Installing " .. name .. "...")
        vim.fn.system({ "git", "clone", "--depth=1", repo, install_path })
        vim.cmd("packadd " .. name)
    end
end

local plugins = {
    -- Libraries
    "https://github.com/nvim-lua/plenary.nvim",

    -- Theme
    "https://github.com/thimc/gruber-darker.nvim",

    -- Treesitter & Syntax
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/tpope/vim-sleuth",
    "https://github.com/folke/todo-comments.nvim",

    -- LSP & Autoformat
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/saghen/blink.cmp", 

    -- Utilities
    "https://github.com/folke/which-key.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/echasnovski/mini.nvim",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/lewis6991/gitsigns.nvim",
}

-- Install all plugins
for _, repo in ipairs(plugins) do
    ensure(repo)
end

-- Generate help tags for new plugins
vim.cmd("silent! helptags ALL")

local pack_path = vim.fn.stdpath("data") .. "/site/pack/my_plugins/start"
local installed_plugins = vim.fn.readdir(pack_path)

for _, plugin_name in ipairs(installed_plugins) do
    -- 'packadd!' with a bang forces loading even if Neovim thinks it's done
    vim.cmd("packadd! " .. plugin_name)
end

-- Load Configurations
-- We use pcall to safely load configs only if the plugin exists
pcall(require, "plugins.theme")

-- Force add treesitter to RTP before requiring config to prevent "module not found"
vim.cmd("packadd nvim-treesitter")
require("plugins.treesitter")

require("plugins.lsp")
require("plugins.utils")

-- -- Load Configurations
-- -- We wrap these in pcall to prevent errors during the very first install
-- -- (before the plugins are actually on disk).
-- pcall(require, "plugins.theme")
-- require("plugins.treesitter")
-- -- pcall(require, "plugins.treesitter")
-- pcall(require, "plugins.lsp")
-- pcall(require, "plugins.utils")
--
-- -- Update command shortcut
-- vim.keymap.set("n", "<leader>pu", function() 
--     vim.pack.update() 
--     print("Plugins updated! Restart Neovim.")
-- end, { desc = "Update Plugins" })
