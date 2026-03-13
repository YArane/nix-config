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
