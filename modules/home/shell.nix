{ ... }:

{
  programs.zsh = {
    enable = true;

    initExtra = ''
      # Navigation keybindings
      bindkey '^[[1;5D' beginning-of-line  # Ctrl+Left  → beginning of line
      bindkey '^[[1;5C' end-of-line        # Ctrl+Right → end of line
      bindkey '^[[1;3D' backward-word      # Alt+Left   → word back
      bindkey '^[[1;3C' forward-word       # Alt+Right  → word forward
      bindkey '^[[H'    beginning-of-line  # Home
      bindkey '^[[F'    end-of-line        # End
    '';
  };
}
