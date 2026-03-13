{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "pygmalion";
    };

    autosuggestion.enable = true;

    history = {
      size = 100000;
      save = 100000;
    };

    shellAliases = {
      vi = "nvim";

      # eza
      ls = "eza --color=always --group-directories-first --icons";
      ll = "eza -la --icons --git --no-permissions --group-directories-first";
      llm = "eza -lb --header --sort=modified --color=always --icons";
      lls = "eza -lb --header --sort=size --reverse --color=always --icons";
      la = "eza -la --icons --octal-permissions --group-directories-first";
      lx = "eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons";
      l = "eza -1 --color=always --group-directories-first --icons";

      # bat
      cat = "bat -pp";

      # nix rebuild
      rebuild = "sudo nixos-rebuild switch --flake ~/nix-config#wsl";
    };

    sessionVariables = {
      TERM = "xterm-256color";
    };

    initContent = ''
      # Navigation keybindings
      bindkey '^[[1;5D' beginning-of-line  # Ctrl+Left  → beginning of line
      bindkey '^[[1;5C' end-of-line        # Ctrl+Right → end of line
      bindkey '^[[1;3D' backward-word      # Alt+Left   → word back
      bindkey '^[[1;3C' forward-word       # Alt+Right  → word forward
      bindkey '^[[H'    beginning-of-line  # Home
      bindkey '^[[F'    end-of-line        # End

      # history: write incrementally, don't share across sessions
      setopt inc_append_history
      unsetopt share_history

      # tree listing function — using eza module's built-in lt alias instead
      # lt() {
      #   local level=''${1:-2}
      #   eza --tree --level="$level" --color=always --group-directories-first --icons
      # }

      # prevent Ctrl-d from exiting shell
      set -o ignoreeof

      # launch tmux on startup
      if [ "$TMUX" = "" ]; then tmux; fi
    '';
  };

  # fzf with shell integration and monokai-inspired colors
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--margin=0"
      "--padding=0"
    ];
    colors = {
      "bg+" = "#293739";
      bg = "#1B1D1E";
      border = "#808080";
      spinner = "#E6DB74";
      hl = "#7E8E91";
      fg = "#F8F8F2";
      header = "#7E8E91";
      info = "#A6E22E";
      pointer = "#A6E22E";
      marker = "#F92672";
      "fg+" = "#F8F8F2";
      prompt = "#F92672";
      "hl+" = "#F92672";
    };
  };

  # eza (ls replacement) — aliases defined above in shellAliases
  programs.eza.enable = true;

  # bat (cat replacement)
  programs.bat.enable = true;

  # zoxide (smarter cd) with shell integration
  programs.zoxide.enable = true;
}
