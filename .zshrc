######################################################
#      ___               ____  ______ _____  _____   #
#     / _ | ___  ___    /_  / / __/ // / _ \/ ___/   #
#    / __ |/ _ \/ _ \    / /__\ \/ _  / , _/ /__     #
#   /_/ |_/_//_/\___/   /___/___/_//_/_/|_|\___/     #
#                                                    #
######################################################
# Author: Anonoei (https://github.com/anonoei)
# License: MIT
## Dependencies
#   - [optional] exa (terminal icons)
#   - zsh-syntax-highlighting
#   - zsh-autosuggestions
#   - zinit (plugins)
#   - fzf (fuzzy finder)
version="0.3.2"
### -------------------------------- ###
#        Aliases
### -------------------------------- ###
if hash exa 2> /dev/null; then
    alias ls="exa --icons"
    alias ll="ls -lh"
    alias la="ls -a"
    alias lla="ls -lha"
else
    alias ls="ls --color -F"
    alias ll="ls --color -lh"
    alias la="ls -A"
    alias lla="ls -lA"
fi
alias q="exit"
alias clr="clear"
alias ..="cd .."
alias mv="nocorrect mv"
alias cp="nocorrect cp"
alias mkdir="nocorrect mkdir"
alias history="history -d"
alias h="history"
alias hc="history -p"
alias help="run-help"

### -------------------------------- ###
#        ZSH Configuration
### -------------------------------- ###
PATH_ZSH="${HOME}/.local/share/.zsh"
if [[ ! -d "$PATH_ZSH" ]]; then
    mkdir -p "$PATH_ZSH"
fi
### ---- History ---- ###
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=${HISTSIZE} # lines of history to save
setopt EXTENDED_HISTORY # add timestamp and duration to command
setopt INC_APPEND_HISTORY # append to histfile instead of rewriting
### ---- Options ---- ###
autoload -U select-word-style
select-word-style bash
setopt AUTO_CD
setopt AUTO_LIST
setopt LIST_PACKED # use columns for listing completions
setopt AUTO_MENU # use menu for ambiguous completions
setopt HASH_LIST_ALL
setopt CORRECT
setopt CORRECT_ALL
setopt IGNORE_EOF
#setopt PRINT_EXIT_VALUE
setopt CHECK_JOBS

# Initialize colors
SupportedColors=0
autoload colors && colors
# foreground colors are lowercase, background colors UPPERCASE
typeset -AHg fg fg_bold fg_no_bold
for k in ${(k)color[(I)fg-*]}; do # foreground colors
    name=${k#fg-} # Get color names from autoload colors, remove 'fg-' prefix
    nameLower="${(L)name}"
    eval $nameLower='%{$fg_no_bold[${(L)name}]%}' # wrap colours between %{ %} to avoid weird gaps in autocomplete
    eval bold_$nameLower='%{$fg_bold[${(L)name}]%}'
    let "SupportedColors=SupportedColors+1"
done
let "SupportedColors=SupportedColors*2" # for bold/non-bold
typeset -AHg bg bg_bold bg_no_bold
for k in ${(k)color[(I)bg-*]}; do # BACKGROUND colors
    name=${k#bg-} # Get color names from autoload colors, remove 'bg-' prefix
    nameUpper="${(U)name}"
    eval $nameUpper='%{$bg_no_bold[${(L)name}]%}' # wrap colours between %{ %} to avoid weird gaps in autocomplete
    eval BOLD_$nameUpper='%{$bg_bold[${(L)name}]%}'
done
eval RESET='%{$reset_color%}'

# git info
autoload -Uz vcs_info # enable vcs_info
zstyle ':vcs_info:*' check-for-changes true
# %s version control system
# %r root directory of repository
# %S relative path to root directory
# %b branch name
# %m info about stashes
# %u unstagd changes
# %c stages changes
zstyle ':vcs_info:git*' formats " ${blue}[${green}%s${blue}/${default}%r${blue}: ${cyan}%b ${yellow}%m%u%c${blue}]${RESET}"
precmd () { vcs_info }
# help info
autoload -Uz run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn

### ---- Install QoL features ---- ###
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "${HOME}/.local/share/zinit" ]]; then
    echo "\033[1;33mInstalling Zinit...\033[0m"
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    source "${ZINIT_HOME}/zinit.zsh"
    exec zsh
fi
if [[ ! -d "$PATH_ZSH/zsh-autosuggestions" ]]; then
    echo "\033[1;33mInstalling zsh-autosuggestions...\033[0m"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PATH_ZSH/zsh-autosuggestions"
fi
if [[ ! -d "$PATH_ZSH/zsh-syntax-highlighting" ]]; then
    echo "\033[1;33mInstalling zsh-syntax-highlighting...\033[0m"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PATH_ZSH/zsh-syntax-highlighting"
fi
if hash fzf 2> /dev/null; then
    zinit snippet "https://github.com/junegunn/fzf/tree/master/shell/key-bindings.zsh"
fi

source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# zsh-syntax-highlighting
if [[ -f $PATH_ZSH/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    . $PATH_ZSH/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_HIGHLIGHT_MAXLENGTH=512
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
fi
## zsh-autosuggestions
if [[ -f $PATH_ZSH/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    . $PATH_ZSH/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=magenta,bold,underline"					# highlight style
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    #ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=
    ZSH_AUTOSUGGEST_BIFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    ZSH_AUTOSUGGEST_HISTORY_IGNORE=""
    ZSH_AUTOSUGGEST_COMPLETION_IGNORE="pacman -S *"
    ZSH_AUTOSUGGEST_COMPLETION_IGNORE="apt install *"
    ZSH_AUTOSUGGEST_COMPLETION_IGNORE="nala install *"
    ZSH_AUTOSUGGEST_COMPLETION_IGNORE="port install *"
    ZSH_AUTOSUGGEST_COMPLETION_IGNORE="brew install *"
fi
### ---- Completion ---- ###
setopt COMPLETE_ALIASES # uses aliases for completion
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

### ---- Confirm commands ---- ###
confirm() {
    local response="y"
    echo -ne "Do you want to run '$*' (y/N)? "
    read -q response
    echo
    case "$response" in
        [yY][eE][sS]|[yY]) command "${@}";;
        *) return false;;
    esac
}
confirm_wrap() {
    if [ "$1" = '--root' ]; then
        local as_root='1'
        shift
    fi
    local prefix=''
    if [ "${as_root}" = '1' ] && [ "${USER}" != 'root' ]; then
        prefix="sudo"
    fi

    confirm ${prefix} "$@"
}

poweroff() { confirm_wrap --root $0 "$@"; }
reboot() { confirm_wrap --root $0 "$@"; }
hibernate() { confirm_wrap --root $0 "$@"; }
# Package managers
pacman() { confirm_wrap --root $0 "$@"; }
apt() { confirm_wrap --root $0 "$@"; }
nala() { confirm_wrap --root $0 "$@"; }
port() { confirm_wrap --root $0 "$@"; }

### -------------------------------- ###
#        Defines
### -------------------------------- ###
### ---- Key bindings ---- ###
bindkey -e

bindkey "^[[3~" delete-char
bindkey "^[[3;5~" kill-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey '^[[Z' reverse-menu-complete

# Clear all values (use default terminal formatting)
NONE='\e[0m'

## Places changes in the order above, IE:
# $TextType $BackgroundColor $TextColor
#
## colored MAN pages ##
man() {
     # mb #
     # md # man titles (ie: NAME, Description, etc)
     # me #
     # se #
     # so # man Bottom Bar
     # ue #
     # us # man References (ie: filename attribute, parameter, zshbuiltins)
  env \
    LESS_TERMCAP_mb=$(printf "${RESET}${bold_blue}") \
    LESS_TERMCAP_md=$(printf "${RESET}${BLACK}${bold_green}") \
    LESS_TERMCAP_me=$(printf "${RESET}") \
    LESS_TERMCAP_se=$(printf "${RESET}") \
    LESS_TERMCAP_so=$(printf "${RESET}${BLUE}${bold_yellow}") \
    LESS_TERMCAP_ue=$(printf "${RESET}") \
    LESS_TERMCAP_us=$(printf "${RESET}${BLACK}${purple}") \
    man "$@"
}

### -------------------------------- ###
#        Prompt Configuration
### -------------------------------- ###
setprompt() {
    setopt prompt_subst
    # man zshmisc

    # <username>@<hostname>:<current-directory [<vsc_info>] >
    PS1=${(j::Q)${(Z:Cn:):-$'
        ${default}%n                # Username
        ${blue}@                    # @
        ${default}%m                # Hostname
        ${blue}:                    # :
        ${green}%~                  # Current Directory
        ${RESET}$vcs_info_msg_0_    # Version control info
        ${white}" ">                # Prompt
        ${RESET}" "
    '}}

    PS2=$'%_>'
    RPROMPT=' ${default}%D{%j %U %F %T%z}${RESET}'
}
setprompt