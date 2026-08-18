{...}: {
  # The launcher reads its bindings from here and nothing else, so the keymap
  # is declared like the rest of the configuration rather than edited in place.
  xdg.configFile."sottomano/keymap.json".source = ../dotfiles/sottomano/keymap.json;
}
