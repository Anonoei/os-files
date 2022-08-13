###########################################################################
#            ___                   _____  _____ __  ______  ______        #
#           /   |  ____  ____     /__  / / ___// / / / __ \/ ____/        #
#          / /| | / __ \/ __ \      / /  \__ \/ /_/ / /_/ / /             #
#         / ___ |/ / / / /_/ /     / /_____/ / __  / _, _/ /___           #
#        /_/  |_/_/ /_/\____/     /____/____/_/ /_/_/ |_|\____/           #
#                                                                         #
###########################################################################
#--------------------------------  Ver 0.2.0  ----------------------------#
###########################################################################
# Author: Anonoei (https://github.com/anonoei)
# License: MIT
## Dependencies
#   - [optional] exa (terminal icons)
#   - zsh-syntax-highlighting
#   - zsh-autosuggestions
#   - zinit (plugins)
#   - fzf (fuzzy finder)
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
alias h="history"
alias help="run-help"

### -------------------------------- ###
#        ZSH Configurations
### -------------------------------- ###
### ---- History ---- ###
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=${HISTSIZE}
setopt SHARE_HISTORY
### ---- Options ---- ###
autoload -U select-word-style
select-word-style bash
setopt autocd
autoload -Uz run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn
### ---- Install QoL features ---- ###
PATH_ZSH="${HOME}/.local/share/.zsh"
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$PATH_ZSH" ]]; then
    mkdir -p "$PATH_ZSH"
fi
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
fi
### ---- Completion ---- ###
setopt COMPLETE_ALIASES
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
confirm()
{
    local response="y"
    echo -ne "Do you want to run '$*' (y/N)? "
    read -q response
    echo
    case "$response" in
        [yY][eE][sS]|[yY]) command "${@}";;
        *) return false;;
    esac
}
confirm_wrap()
{
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

### ---- Color definitions ---- ###
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
strd='\e[0;'
bold='\e[1;'
gray='\e[2;'
italics='\e[3;'
## Background Color ##
BLACK='40;'
RED='41;'
GREEN='42;'
YELLOW='43;'
BLUE='44;'
PURPLE='45;'
CYAN='46;'
WHITE='47;'
## Text Color ##
black='30m'
red='31m'
green='32m'
yellow='33m'
blue='34m'
purple='35m'
cyan='36m'
white='37m'

# Clear all values (use default terminal formatting)
NONE='\e[0m'

## Places changes in the order above, IE:
# $TextType $BackgroundColor $TextColor
#
## colored MAN pages ##
man()
{
     # mb #
     # md # man titles (ie: NAME, Description, etc)
     # me #
     # se #
     # so # man Bottom Bar
     # ue #
     # us # man References (ie: filename attribute, parameter, zshbuiltins)
  env \
    LESS_TERMCAP_mb=$(printf "$NONE$bold$blue") \
    LESS_TERMCAP_md=$(printf "$NONE$bold$BLACK$green") \
    LESS_TERMCAP_me=$(printf "$NONE") \
    LESS_TERMCAP_se=$(printf "$NONE") \
    LESS_TERMCAP_so=$(printf "$NONE$bold$BLUE$yellow") \
    LESS_TERMCAP_ue=$(printf "$NONE") \
    LESS_TERMCAP_us=$(printf "$NONE$italics$green") \
    man "$@"
}

### -------------------------------- ###
#        Prompt Configuration
### -------------------------------- ###
setprompt()
{
  setopt prompt_subst

  if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
    p_host='%F{red}"ssh:"%M%f'
  else
    p_host='%F{cyan}%M%f'
  fi

    # [username@hostname][current-directory] >
  PS1=${(j::Q)${(Z:Cn:):-$'
    %(!.%F{red}%n%f.%F{cyan}%n%f)      ### Username
    %F{blue}@%f                         ### @
    ${p_host}                           ### Hostname
    :%f                        ### :
    %F{blue}%d%f                        ### Current Directory
    %(!.%F{red}" ">%f.%F{cyan}" ">%f)	###	Prompt
    " "
  '}}

  PS2=$'%_>'
	  # show time in HH:MM:SS on right side
  RPROMPT=' %F{white}$(date +%F)_$(date +%T)%f'
}
setprompt