{ lib, pkgs, config, ... }:

{
  # IdeaVim config for IntelliJ IDEA
  # On macOS, IntelliJ reads ~/.ideavimrc directly.
  # On WSL, the activation script copies it to the Windows home directory.
  home.file.".ideavimrc".text = ''
    inoremap jk <esc>

    let mapleader=","

    " move vertically by visual line
    noremap j gj
    noremap k gk

    " searching
    set incsearch      " search as characters are entered
    set hlsearch       " highlight matches
    set showmatch      " highlight matching [{()}]

    " clear search
    nnoremap <leader><space> :nohlsearch<CR>

    " highlight last inserted text
    nnoremap gV `[v`]

    set visualbell
    set noerrorbells

    set clipboard+=unnamed  " yank to system clipboard
  '';

  # On WSL, IntelliJ runs as a Windows app and reads .ideavimrc from
  # the Windows home directory. Copy the HM-generated file there on every rebuild.
  home.activation.copyIdeavimrcToWindows = lib.mkIf pkgs.stdenv.isLinux (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      win_user="$(/mnt/c/Windows/system32/cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')"
      if [ -z "$win_user" ]; then
        echo "WARNING: Could not detect Windows username; skipping .ideavimrc copy"
      else
        run install -m 644 "${config.home.homeDirectory}/.ideavimrc" "/mnt/c/Users/$win_user/.ideavimrc"
      fi
    ''
  );
}
