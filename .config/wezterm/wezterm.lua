local wezterm = require 'wezterm';

return {
  initial_rows = 48,
  initial_cols = 120,
  window_background_opacity = 0.95,

  font = wezterm.font(
    "Hack Nerd Font Mono", { weight = "DemiBold", stretch="Normal", style="Normal" }
  ), 
  freetype_load_target = "Light",
  -- freetype_load_flags = "NO_BITMAP",
  harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
  warn_about_missing_glyphs = false,


  font_size = 12.0,
  use_ime = true, 
 
  color_scheme = "Pencil Dark", -- https://wezfurlong.org/wezterm/colorschemes/index.html
  -- color_scheme = "Homebrew",
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = true,
  enable_scroll_bar = true,
  exit_behavior = "CloseOnCleanExit",
	tab_bar_at_bottom = true,
	window_close_confirmation = "AlwaysPrompt",
  adjust_window_size_when_changing_font_size = false,
}
