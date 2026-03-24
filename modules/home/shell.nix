{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "pygmalion";
      extraConfig = ''
        # Skip all plugin aliases — lets our shellAliases be the sole source
        zstyle ':omz:plugins:*' aliases no
      '';
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

      # secrets
      sops = "nix shell nixpkgs#sops nixpkgs#age -c sops";

      # nix rebuild
      rebuild =
        if pkgs.stdenv.isLinux
        then "sudo nixos-rebuild switch --flake ~/nix-config#wsl"
        else "sudo darwin-rebuild switch --flake ~/nix-config#darwin";
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

      # Fix tab completion for eza aliases (ls, ll, etc.)
      # By default zsh expands aliases before looking up completers, so "ls <TAB>"
      # runs the _eza completer (since ls aliases to eza). _eza's completer then
      # offers --color= values (always, auto, never) instead of just files.
      # COMPLETE_ALIASES stops alias expansion during completion, and compdef _files
      # tells zsh to use plain file completion for these alias names.
      setopt COMPLETE_ALIASES
      compdef _files ls l la ll llm lls lx

      # prevent Ctrl-d from exiting shell
      set -o ignoreeof

      # smart Ctrl+R: history search when line is empty, file picker when there's text
      fzf-smart-widget() {
        if [[ -z "$BUFFER" ]]; then
          fzf-history-widget
        else
          local orig="$LBUFFER"
          LBUFFER="''${LBUFFER}**"
          fzf-completion
          # clean up leftover ** if completion was cancelled
          if [[ "$LBUFFER" == *'**' ]]; then
            LBUFFER="$orig"
          fi
        fi
      }
      zle -N fzf-smart-widget
      bindkey '^R' fzf-smart-widget

      # launch tmux on startup — skip when IntelliJ (or other IDEs) spawn
      # shells to read the environment; without these guards each spawned
      # shell creates a stray tmux session in /tmp
      if [ "$TMUX" = "" ] && [ -z "$TERMINAL_EMULATOR" ] && [ -z "$INTELLIJ_ENVIRONMENT_READER" ] && [[ "$PWD" != /tmp/* ]]; then tmux; fi
    '';
  };

  # fzf with shell integration — AstroTheme astrodark palette
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      #"--border=none"
      "--border"
      "--margin=0"
      "--padding=0"
      "--highlight-line"
      #"--info=inline-right"
      "--ansi"
    ];
    colors = {
      "bg+"      = "#3A3E47";
      bg         = "#1A1D23";
      border     = "#9B9FA9";
      "fg+"      = "#ADB0BB";
      fg         = "#ADB0BB";
      gutter     = "#1A1D23";
      header     = "#50A4E9";
      "hl+"      = "#5EB7FF";
      hl         = "#5EB7FF";
      info       = "#9B9FA9";
      marker     = "#5EB7FF";
      pointer    = "#5EB7FF";
      prompt     = "#5EB7FF";
      query      = "#ADB0BB:regular";
      scrollbar  = "#9B9FA9";
      separator  = "#9B9FA9";
      spinner    = "#5EB7FF";
    };
  };

  # eza (ls replacement) — aliases defined above in shellAliases
  programs.eza.enable = true;

  # bat (cat replacement)
  programs.bat.enable = true;

  # zoxide (smarter cd) with shell integration
  programs.zoxide.enable = true;

  # direnv — auto-activates per-project devShells on cd
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # caches devShell environments
  };
}
