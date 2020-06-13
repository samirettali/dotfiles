ZSH_THEME_GIT_PROMPT_PREFIX='['
ZSH_THEME_GIT_PROMPT_SUFFIX=']'
ZSH_THEME_GIT_PROMPT_SEPARATOR=''
RPROMPT='$(git_super_status)'
export PS1="%F{blue}${SSH_CONNECTION:+%B%n@%m%B}%f%B${SSH_CONNECTION:+:}%b%F{blue}%B%1d%b%F{yellow}%B%(1j.*.)%(?..!)%b%f%B%F{red}$%f%b "
