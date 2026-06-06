-- 1. Setup Blink Completion
require("blink.cmp").setup({
    keymap = {
        preset = "default",
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Esc>"] = { "hide", "fallback" },
    },
    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
    },
    sources = { default = { "lsp", "path", "snippets" } },
    fuzzy = {
        prebuilt_binaries = {
            download = true,
            force_version = "v1.9.1",
        },
    },
})

-- 2. Native LSP Setup (0.12)
-- Note: We use lspconfig for the configurations, but native calls to enable them.

-- C# (Omnisharp)
vim.lsp.config("omnisharp", {
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    enable_roslyn_analyzers = true,
    organize_imports_on_format = true,
    enable_import_completion = true,
})
vim.lsp.enable("omnisharp")

-- ADD THIS: TypeScript / JavaScript
vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
})
vim.lsp.enable("ts_ls")

-- ADD THIS: JSON (Helpful for manifest.json)
-- Run: npm install -g vscode-langservers-extracted
vim.lsp.config("jsonls", {
    cmd = { "vscode-json-language-server", "--stdio" },
})
vim.lsp.enable("jsonls")

-- C / C++ (Clangd)
vim.lsp.config("clangd", { 
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
})
vim.lsp.enable("clangd")

-- Godot (GDScript)
vim.lsp.config("gdscript", {
    cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
})
vim.lsp.enable("gdscript")

-- Lua
vim.lsp.config("lua_ls", {
    settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})
vim.lsp.enable("lua_ls")

-- 3. Autoformatting
require("conform").setup({
    notify_on_error = false,
    formatters_by_ft = {
        lua = { 'stylua' },
        c_sharp = { 'csharpier' },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
    },
})

-- 4. Keymaps (LspAttach)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        client.server_capabilities.semanticTokensProvider = nil

        local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
        end

        map("gd", vim.lsp.buf.definition, "Goto Definition")
        map("gr", vim.lsp.buf.references, "Goto References")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
    end,
})
