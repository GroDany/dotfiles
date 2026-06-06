require("nvim-treesitter.config").setup({
    ensure_installed = { 
        "c", "c_sharp", "lua", "vim", "vimdoc", "markdown", 
        "gdscript", "godot_resource", "gdshader", "bash", "diff",
        "typescript", "tsx", "javascript", "html", "css", "json"
    },
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local filetype = args.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if vim.treesitter.language.add(lang) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.treesitter.start()
    end
  end
})
