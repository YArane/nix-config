{ pkgs, ... }:

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
      bind-key -n MouseDown3Pane run "tmux set-buffer \"\$(powershell.exe -c Get-Clipboard | tr -d '\\r')\"; tmux paste-buffer"
      #bind-key -n MouseDown3Pane run "tmux set-buffer \"\$(pbpaste)\"; tmux paste-buffer"

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
    fzf
    fd
    zoxide
  ];
}
