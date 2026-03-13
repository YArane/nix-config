-- Tools installed via Nix instead of Mason.
-- On NixOS, Mason-downloaded binaries with complex dependency chains
-- (e.g. .NET apps like marksman) fail even with nix-ld.
-- Installing them through Nix bundles all dependencies correctly.
--
-- Two things must happen for each Nix-installed LSP:
-- 1. Filter it from mason-tool-installer so Mason doesn't install a broken copy
-- 2. Add it to AstroLSP's servers list so lspconfig sets it up without Mason

local nix_installed = {
  "marksman",
  "nixd",
}

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(tool)
        local name = type(tool) == "string" and tool or tool[1]
        return not vim.tbl_contains(nix_installed, name)
      end, opts.ensure_installed or {})
    end,
  },
  {
    "AstroNvim/astrolsp",
    opts = {
      servers = nix_installed,
    },
  },
}
