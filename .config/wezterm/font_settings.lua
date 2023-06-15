local wezterm = require 'wezterm'
local fs = {};

if wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then 
  fs.font = wezterm.font_with_fallback({
    {
      family = "Hack Nerd Font Mono",
      harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
      weight = "DemiBold", stretch="Normal", style="Normal"
    },
    {
      family = "Hiragino Kaku Gothic Pro",
      harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
      weight="DemiBold", stretch="Normal", style="Normal"
    },
  })
elseif wezterm.target_triple == 'x86_64-unknown-linux-gnu' then
  fs.font = wezterm.font_with_fallback({
    {
      family = "NotoSansM Nerd Font Mono",
      harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
      weight = "DemiBold", stretch="Normal", style="Normal"
    },
  })
end

return fs
