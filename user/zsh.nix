{ lib, config, pkgs, ... }:

{
  programs =  {
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

# Prompt (Heavily inspired from Greg Hurrell)
# https://github.com/wincent/wincent
function () {
  if [[ "$TERM_PROGRAM" == 'vscode' ]]; then
    local LVL=$(($SHLVL - 3))
  elif [[ -n "$TMUX" ]]; then
    local LVL=$(($SHLVL - 2))
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
          function ls () {
            command ls --color=auto --group-directories-first $@
          }
          # Create new tmux session with name if passed
          function t() {
              if [ -z "$1" ]; then
                  tmux
              else
                  tmux new -A -s "$1"
              fi
          }

          # Throw away directory
          function tad() {
              local ts=$(date +%s)
              local d="$HOME/.throw-away/$ts"
              mkdir -p "$d"
              (cd "$d"; zsh -c tmux)
              rm -rf "$d"
          }

          # Go to git repository root
          function gr() {
              readonly old_pwd="$PWD"
              while [[ 1 ]]; do
                  cd ..
                  if [[ "$PWD" == "/" ]]; then
                      cd "$old_pwd"
                      echo "No repository found, returned to $PWD"
                      return 1
                  fi
                  for repo in ".git" ".hg"; do
                      if [[ -d "$repo" ]]; then
                          echo "Found $repo at $PWD"
                          return 0
                      fi
                  done
              done
          }

          function up() {
            cd $(printf "%0.s../" $(seq 1 $1 ));
          }

          function loadenv() {
            if [[ -f .env ]]; then
              export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
              length=$(wc -l < .env)
              echo "Loaded $length variables"
            fi

          }

          function take() {
              mkdir -p "$1"
              cd "$1"
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
export PATH=$PATH:~/.bin:~/go/bin
        '';
        # promptInit = "autoload -U promptinit && promptinit && prompt suse && setopt prompt_sp";
        shellAliases = {
          tl = "tmux ls";
          qre = "qrencode -l H -t ANSI256UTF8";
          qrd = "pngpaste - | zbarimg -q --raw - | tee | pbcopy";
          lg = "lazygit";
          ld = "lazydocker";
          c = "tee | xsel -ib";
          vim = "nvim";
          fim = "nvim $(fd -t f | fzf)";

          gc = "git clone";
          gl = "git log --graph --abbrev-commit --decorate --format=format:\"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)\" --all";
          gwho = "git log --format='%aN' | sort | uniq -c | sort -nr";

          ytdl = "youtube-dl -R infinite -f bestvideo+bestaudio --output \"%(title)s.%(ext)s\"";
          ytmp3 = "youtube-dl -R infinite -i --extract-audio --audio-format mp3 --audio-quality 0 -w --output \"%(title)s.%(ext)s\"";

          jj = "pbpaste | jq -r | pbcopy";
          jjj = "pbpaste | jq -r";

          rm = "trash";
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
