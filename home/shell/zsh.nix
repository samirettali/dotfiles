{ lib
, config
, pkgs
, ...
}: {
  programs = {
    zsh = {
      enable = true;
      # TODO uncomment these when removing submodules from dotfiles repo
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      completionInit = ''
        zstyle ':completion:*' menu select
        zstyle ':completion:*' list-colors "''${(@s.:.)LSCOLORS}"
        zstyle ':completion:*' completer _last_command_args _complete

        # Add a package to completion right after install
        zstyle ':completion:*' rehash true

        # Mismatch completion
        zstyle ':completion:*' completer _complete _match _approximate
        zstyle ':completion:*:match:*' original only
        zstyle ':completion:*:approximate:*' max-errors 1 numeric

        # Don't autocomplete with files already present in the command
        zstyle ':completion::complete:(rm|vi|vim|diff|mv):*' ignore-line true

        # Complete by expanding
        zstyle ':completion:*' list-suffixeszstyle ':completion:*' expand prefix suffix
      '';
      defaultKeymap = "viins";
      history = {
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        ignorePatterns = [
          # These patterns are not added to history to prevent accidental execution
          "rm *"
          "pkill *"
          "shutdown"
          "reboot"
          "ls *"
          "exit"
          "clear"
        ];
        ignoreSpace = true;
        share = true; # Share history between sessions
        # historySubstirngSearch
      };
      initExtra = ''
        # Git prompt
        autoload -Uz vcs_info
        precmd_vcs_info() { vcs_info }
        precmd_functions+=( precmd_vcs_info )
        setopt prompt_subst
        RPROMPT=\$vcs_info_msg_0_
        zstyle ':vcs_info:git:*' formats '%F{magenta}%B[%b]%%b%f'
        zstyle ':vcs_info:*' enable git

        # Prompt
        function () {
          if [[ "$TERM_PROGRAM" == 'vscode' ]]; then
            local LVL=$(($SHLVL - 3))
          elif [[ -n "$TMUX" ]]; then
            local LVL=$(($SHLVL - 3))
          else
            # Simple terminal
            local LVL=$SHLVL-2
          fi

          if [[ $EUID -eq 0 ]]; then
            local SUFFIX=$(printf '\#%.0s' {1..$LVL})
          else
            local SUFFIX=$(printf '\$%.0s' {1..$LVL})
          fi

          # Show user@host if I'm in SSH or docker
          if [[ $SSH_CONNECTION ]] || [[ -f /.dockerenv ]]; then
            export PS1="%B%F{blue}%n@%m%f:%F{blue}%1~%F{yellow}%(1j.*.)%(?..!)%f%F{red}''${SUFFIX}%f%b "
          else
            export PS1="%B%F{blue}%1~%F{yellow}%(1j.*.)%(?..!)%f%F{red}''${SUFFIX}%f%b "
          fi
        }

        ## TODO do this only if gui
        autoload -U url-quote-magic bracketed-paste-magic
        zle -N self-insert url-quote-magic
        zle -N bracketed-paste bracketed-paste-magic

        pasteinit() {
            OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
            zle -N self-insert url-quote-magic
        }

        pastefinish() {
            zle -N self-insert $OLD_SELF_INSERT
        }

        zstyle :bracketed-paste-magic paste-init pasteinit
        zstyle :bracketed-paste-magic paste-finish pastefinish

        ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste accept-line)

        # keybindings
        bindkey '^F' fzf-file-widget
        bindkey '^ ' autosuggest-accept

        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey '^x^x' edit-command-line

        function fg-bg() {
            if [[ $#BUFFER -eq 0 ]]; then
                fg
            else
                zle push-input
            fi
        }
        zle -N fg-bg
        bindkey '^Z' fg-bg

        export PATH=~/.bin:$PATH:~/.dotnet/tools
      '';
      shellAliases = {
        t = "tmux new -A -s";
        tl = "tmux ls";

        lg = "lazygit";
        ld = "lazydocker";

        vim = "nvim";
        fim = "nvim $(fd -t f | fzf)";

        sl = "ls";
        gc = "git clone";
        rm = "trash";
        # jj = "pbpaste | jq -r | pbcopy";
        # jjj = "pbpaste | jq -r";
      };
      shellGlobalAliases = {
        trim = "awk '{\$1=\$1;print}'";
      };
      sessionVariables = {
        KEYTIMEOUT = "1";
      };
    };
  };
}
