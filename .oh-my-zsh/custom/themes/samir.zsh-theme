ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_SEPARATOR=""
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg_bold[red]%}%{✖●%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg_bold[blue]%}%{✚%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[yellow]%}%{?%G%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
RPROMPT_BASE='$(git_super_status)'

export PS1="%B%F{blue}%1d%F{yellow}%(1j.*.)%(?..!)%f%F{red}$%f%b "
