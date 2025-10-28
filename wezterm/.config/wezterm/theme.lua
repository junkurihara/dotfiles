local wezterm = require 'wezterm';

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

return scheme_for_appearance(wezterm.gui.get_appearance())
