-- Tools installed via Nix instead of Mason.
-- On NixOS, Mason-downloaded binaries (pip/npm packages, .NET apps) often fail.
-- Installing them through Nix bundles all dependencies correctly.
--
-- LSP servers need two things:
-- 1. Filter from mason-tool-installer so Mason doesn't install a broken copy
-- 2. Add to AstroLSP's servers list so lspconfig sets them up without Mason
--
-- Non-LSP tools (formatters, linters, debug adapters) only need step 1.
-- none-ls and nvim-dap find them on $PATH automatically.

-- LSP servers: must be both filtered from Mason AND registered with AstroLSP
local nix_lsp_servers = {
  "basedpyright",
  "marksman",
  "nixd",
  "sqls",
}

-- Non-LSP tools (formatters, linters, debug adapters): only need Mason filtering.
-- none-ls / nvim-dap find these on $PATH automatically.
local nix_tools = {
  "black",
  "debugpy",
  "isort",
  "ruff",
  "sqlfluff",
}

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      local skip = vim.list_extend(
        vim.list_extend({}, nix_lsp_servers),
        nix_tools
      )
      opts.ensure_installed = vim.tbl_filter(function(tool)
        local name = type(tool) == "string" and tool or tool[1]
        return not vim.tbl_contains(skip, name)
      end, opts.ensure_installed or {})
    end,
  },
  {
    "AstroNvim/astrolsp",
    opts = {
      servers = nix_lsp_servers,
    },
  },
}
