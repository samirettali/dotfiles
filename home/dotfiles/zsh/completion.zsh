zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LSCOLORS}"
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
