local wezterm = require 'wezterm'
local act = wezterm.action
local kb = {}

kb.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 3000 }
 
-- # Vimのキーバインドでペインを移動する
-- bind h select-pane -L
-- bind j select-pane -D
-- bind k select-pane -U
-- bind l select-pane -R
-- bind -r C-h select-window -t :-
-- bind -r C-l select-window -t :+
kb.keys = {
  -- tmux key bindings for pane
  {
    key = '|',
    mods = 'LEADER|SHIFT',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '-',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
}

return kb
