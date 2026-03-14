{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
  };

  # Place AstroNvim config into ~/.config/nvim/
  # recursive = true creates per-file symlinks, so lazy.nvim can
  # write lazy-lock.json and other runtime files alongside them.
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  home.packages = with pkgs; [
    # Treesitter needs a C compiler to build parsers
    gcc
    gnumake

    # LSP servers installed via Nix (Mason can't run these on NixOS)
    marksman      # markdown LSP (.NET binary — needs libicu, which Mason doesn't provide)
    nixd          # Nix LSP server (used by the nix community pack)
    deadnix       # Nix dead code linter (used by none-ls via the nix community pack)
    basedpyright  # Python LSP (python pack)
    ruff          # Python linter/formatter (python pack)
    black         # Python formatter (python pack)
    isort         # Python import sorter (python pack)
    python3Packages.debugpy  # Python debug adapter (python pack)
    sqls          # SQL LSP (sql pack)
    sqlfluff      # SQL linter/formatter (sql pack)

    # Telescope dependencies
    ripgrep
    fd

    # Tree-sitter CLI (for :TSInstall)
    tree-sitter

    # Mason dependencies (Mason downloads LSP binaries, needs these)
    unzip
    wget
    curl
    gnutar
    gzip
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    wl-clipboard
  ];
}
