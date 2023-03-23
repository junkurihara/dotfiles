local wezterm = require 'wezterm';
local keybinds = require 'keybinds';

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = wezterm.truncate_right(utils.basename(tab.active_pane.foreground_process_name), max_width)
	if title == "" then
		title = wezterm.truncate_right(
			utils.basename(utils.convert_home_dir(tab.active_pane.current_working_dir)),
			max_width
		)
	end
	return {
		{ Text = tab.tab_index + 1 .. ":" .. title },
	}
end)

return {
  initial_rows = 48,
  initial_cols = 120,
  window_background_opacity = 0.95,

  font = wezterm.font_with_fallback({
    {
      family = "Hack Nerd Font Mono",
      harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
      weight = "DemiBold", stretch="Normal", style="Normal"
    },
    {
      family = "Hiragino Kaku Gothic Pro",
      harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
      weight="DemiBold", stretch="Normal", style="Normal"
    }
  }), 
  freetype_load_target = "Light",
  -- freetype_load_flags = "NO_BITMAP",
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

  ----
  leader = keybinds.leader,
  keys = keybinds.keys,
}
