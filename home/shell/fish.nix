{
  customArgs,
  lib,
  pkgs,
  ...
}: let
  brewCommand = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  baseInitFile = builtins.readFile ../../home/dotfiles/init.fish;
  initFile =
    if pkgs.stdenv.isDarwin
    then builtins.concatStringsSep "\n" [baseInitFile brewCommand]
    else baseInitFile;
in {
  home.packages = with pkgs; [
    grc
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit =
      initFile
      + "\n"
      +
      /*
      fish
      */
      ''
        function vr
            # Check if ripgrep query was provided
            if test (count $argv) -eq 0
                echo "Usage: vr <search_pattern>"
                return 1
            end

            # Directories to exclude from search
            set -l excluded_dirs .git .venv venv node_modules __pycache__ .pytest_cache dist build target .next .nuxt coverage .coverage

            # Build glob patterns for excluded directories
            set -l glob_patterns
            for dir in $excluded_dirs
                set -a glob_patterns --glob "!$dir/*"
            end

            # Run ripgrep and get results, excluding directories
            set -l rg_results (${lib.getExe pkgs.ripgrep} --vimgrep $glob_patterns $argv)

            # Check if any matches were found
            if test (count $rg_results) -eq 0
                echo "No matches found for: $argv"
                return 1
            end

            # Get the first match details
            set -l first_match (echo $rg_results[1])
            set -l file_path (echo $first_match | cut -d: -f1)
            set -l line_number (echo $first_match | cut -d: -f2)
            set -l column_number (echo $first_match | cut -d: -f3)

            # Check if there are multiple matches
            if test (count $rg_results) -gt 1
                # Multiple matches: create quickfix file and open with quickfix list
                set -l qf_file (mktemp)
                printf "%s\n" $rg_results > $qf_file
                ${lib.getExe pkgs.neovim} "+call cursor($line_number, $column_number)" "+cgetfile $qf_file" "+copen" "+wincmd p" "$file_path"
                rm $qf_file
            else
                # Single match: just open the file at the exact position
                ${lib.getExe pkgs.neovim} "+call cursor($line_number, $column_number)" "$file_path"
            end
        end
      '';
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
    # TODO: move
    shellAliases = {
      iip = "dig +short myip.opendns.com @resolver1.opendns.com";
      jj = "${customArgs.commands.paste} | ${lib.getExe pkgs.jq} -r | ${customArgs.commands.copy}";
      jjj = "${customArgs.commands.paste} | ${lib.getExe pkgs.jq} -r";
      localip = "ipconfig getifaddr en0";
      ns = "nix-shell --run fish -p";
      rm = lib.getExe pkgs.trash-cli;
    };
  };
}
