{ ... }:
{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!node_modules/*"
      "--colors=line:none"
      "--colors=line:style:bold"
      "--hidden"
      "--smart-case"
    ];
  };
}

