{ lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    historyLimit = 10000;
    escapeTime = 0;
    keyMode = "vi";

    # use 256-color and true-color capable terminal
    terminal = "xterm-256color";

    extraConfig = ''
      # terminal overrides for true color
      set-option -sa terminal-overrides ',xterm-256color:RGB'
      set-option -sa terminal-overrides ',alacritty:Tc'
      set-option -g focus-events on

      # reload config
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # disable right-click context menu; paste from clipboard instead
      unbind -n MouseDown3Pane
      unbind -n MouseDown3Status
      unbind -n MouseDown3StatusLeft
      unbind -n MouseDown3StatusRight
      ${lib.optionalString pkgs.stdenv.isLinux ''bind-key -n MouseDown3Pane run "tmux set-buffer \"\$(powershell.exe -c Get-Clipboard | tr -d '\\r')\"; tmux paste-buffer"''}
      ${lib.optionalString pkgs.stdenv.isDarwin ''bind-key -n MouseDown3Pane run "tmux set-buffer \"\$(pbpaste)\"; tmux paste-buffer"''}

      # vi status keys (command prompt)
      set -g status-keys vi

      # vi copy-mode bindings
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

      # don't exit tmux when closing a session
      set -g detach-on-destroy off

      # move pane to its own window
      bind-key b break-pane -d

      # quick pane cycling
      unbind ^A
      bind ^A select-pane -t :.+

      bind-key C-j choose-tree

      # swap panes vi style
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # resize panes
      bind-key < resize-pane -L 5
      bind-key > resize-pane -R 5
      bind-key + resize-pane -U 5
      bind-key - resize-pane -D 5
      bind-key = select-layout even-vertical
      bind-key | select-layout even-horizontal

      # increase display message time
      set-option -g display-time 2000

      # ── AstroTheme — astrodark palette ──
      set -g mode-style "fg=#50A4E9,bg=#26343F"
      set -g message-style "fg=#50A4E9,bg=#26343F"
      set -g message-command-style "fg=#50A4E9,bg=#26343F"
      set -g pane-border-style "fg=#9B9FA9"
      set -g pane-active-border-style "fg=#50A4E9"
      set -g status "on"
      set -g status-justify "left"
      set -g status-style "fg=#50A4E9,bg=#111317"
      set -g status-left-length "100"
      set -g status-right-length "100"
      set -g status-left-style NONE
      set -g status-right-style NONE
      set -g status-left "#[fg=#1A1D23,bg=#50A4E9,bold] #S #[fg=#50A4E9,bg=#111317,nobold,nounderscore,noitalics]"
      set -g status-right "#[fg=#111317,bg=#111317,nobold,nounderscore,noitalics]#[fg=#50A4E9,bg=#111317] #{prefix_highlight} #[fg=#26343F,bg=#111317,nobold,nounderscore,noitalics]#[fg=#50A4E9,bg=#26343F] %Y-%m-%d  %I:%M %p #[fg=#50A4E9,bg=#26343F,nobold,nounderscore,noitalics]#[fg=#1A1D23,bg=#50A4E9,bold] #h "
      if-shell '[ "$(tmux show-option -gqv "clock-mode-style")" = "24" ]' {
        set -g status-right "#[fg=#111317,bg=#111317,nobold,nounderscore,noitalics]#[fg=#50A4E9,bg=#111317] #{prefix_highlight} #[fg=#26343F,bg=#111317,nobold,nounderscore,noitalics]#[fg=#50A4E9,bg=#26343F] %Y-%m-%d  %H:%M #[fg=#50A4E9,bg=#26343F,nobold,nounderscore,noitalics]#[fg=#1A1D23,bg=#50A4E9,bold] #h "
      }
      setw -g window-status-activity-style "underscore,fg=#696C76,bg=#111317"
      setw -g window-status-separator ""
      setw -g window-status-style "NONE,fg=#696C76,bg=#111317"
      setw -g window-status-format "#[fg=#111317,bg=#111317,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#111317,bg=#111317,nobold,nounderscore,noitalics]"
      setw -g window-status-current-format "#[fg=#111317,bg=#26343F,nobold,nounderscore,noitalics]#[fg=#50A4E9,bg=#26343F,bold] #I  #W #F #[fg=#26343F,bg=#111317,nobold,nounderscore,noitalics]"
      set -g @prefix_highlight_output_prefix "#[fg=#D09214]#[bg=#111317]#[fg=#111317]#[bg=#D09214]"
      set -g @prefix_highlight_output_suffix ""

      # sesh session picker (C-a C-a)
      bind-key C-a run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --layout=reverse \
          --header '  ^a all ^t tmux ^g configs ^e zoxide ^X tmux kill ^F find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-e:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-F:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-X:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\""

      # sesh last session
      bind -N "last-session (via sesh) " L run-shell "sesh last"

      # pull a pane from another window into this one
      bind P choose-tree -Z "join-pane -s '%%'"
      bind -N 'Interactively select a pane and pull it into the current window' P

      # break current pane and send it to selected window
      bind B choose-tree -Z "break-pane -s '%%'"
      bind -N 'Break current pane and send it to selected window' B
    '';
  };

  # sesh dependencies: fzf for the picker, fd for the find binding, zoxide for directory sessions
  home.packages = with pkgs; [
    sesh
  ];
}
