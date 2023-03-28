local wezterm = require 'wezterm';
local keybinds = require 'keybinds';
local theme = require 'theme';
local font_settings = require 'font_settings';

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

function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "Catppuccin Mocha"
  else
    return "Catppuccin Macchiato"
  end
  -- color_scheme = "Ocean Dark (Gogh)",
  -- color_scheme = "VSCodeDark+ (Gogh)", -- https://wezfurlong.org/wezterm/colorschemes/index.html
  -- color_scheme = "Homebrew",
end

return {
  initial_rows = 48,
  initial_cols = 120,
  window_background_opacity = 0.95,

  font = font_settings.font,
  freetype_load_target = "Light",
  -- freetype_load_flags = "NO_BITMAP",
  warn_about_missing_glyphs = false,


  font_size = 12.0,
  use_ime = true, 
 
  color_scheme = theme,

  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = true,
  enable_scroll_bar = true,
  -- exit_behavior = "CloseOnCleanExit",
  exit_behavior = "Close",
	tab_bar_at_bottom = true,
	window_close_confirmation = "AlwaysPrompt",
  adjust_window_size_when_changing_font_size = false,

  ----
  leader = keybinds.leader,
  keys = keybinds.keys,
}
