local wezterm = require 'wezterm';

return {
  initial_rows = 36,
  initial_cols = 100,
  font = wezterm.font("Hack Nerd Font Mono"), -- 自分の好きなフォントいれる
  use_ime = true, -- wezは日本人じゃないのでこれがないとIME動かない
  font_size = 12.0,
  color_scheme = "OneHalfDark", -- 自分の好きなテーマ探す https://wezfurlong.org/wezterm/colorschemes/index.html
  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,
}
