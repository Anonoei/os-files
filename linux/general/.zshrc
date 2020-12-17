###########################################################################
#                                                                         #
#      MMM      MM        MMMMM     MMM    M  M         MMM      MMM      #
#      M  M    M  M          M     M       M  M         M  M    M         #
#      M  M    MMMM         M       MM     MMMM         MMM     M         #
#      M  M    M  M        M          M    M  M         M  M    M         #
#      MMM     M  M       MMMMM    MMM     M  M    X    M  M     MMM      #
#                                                                         #
###########################################################################
#--------------------------------  Ver 0.1.2  ----------------------------#
###########################################################################
# Author: Devon Adams (https://github.com/devonadams)
# License: GPLv3
##########################
#
##   .zshrc    ZSH Resource File
#
#    This file serves as an easy to install profile
#    for using zsh with some better settings
#    Having zsh-syntax-highlighting and zsh-autosuggestions is recommended

### ----------------------------- ###
#     Define Aliases
### ----------------------------- ###
alias mv='nocorrect mv'				  # no spelling correction on mv
alias cp='nocorrect cp'				  # no spelling correction on cp
alias mkdir='nocorrect mkdir'		# no spelling correction on mkdir
alias h='history'
alias ls="ls --color -F"
alias ll="ls --color -lh"

### ----------------------------- ###
#     Basic ZSH Configurations
### ----------------------------- ###
#
## Personal Preferance Variables ##
export EDITOR="/usr/bin/nano"
export BROWSER="chromium"
#
## History Settings ##
HISTFILE=~/.zsh_hist
HISTSIZE=10000
SAVEHIST=${HISTSIZE}
#
## Recent Directory Settings ##
autoload -Uz add-zsh-hook
DIRSTACKFILE="${XDG_CACHE_HOME:-$HOME/.zsh_dirs}"
if [[ -f "$DIRSTACKFILE" ]] && (( ${#dirstack} == 0 )); then
	dirstack=("${(@f)"$(< "$DIRSTACKFILE")"}")
	[[ -d "${dirstack[1]}" ]] && cd -- "${dirstack[1]}"
fi
chpwd_dirstack() {
	print -l -- "$PWD" "${(u)dirstack[@]}" > "$DIRSTACKFILE"
}
add-zsh-hook -Uz chpwd chpwd_dirstack
DIRSTACKSIZE='20'
setopt AUTO_PUSHD PUSHD_SILENT PUSHD_TO_HOME
#
## Remove duplicate entries
setopt PUSHD_IGNORE_DUPS
#
## This reverts the +/- operators.
setopt PUSHD_MINUS
#
## Help command ##
autoload -Uz run-help
unalias run-help
alias help=run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn
#
## Other things can go here (Variables) ##

### ----------------------------- ###
#     Source some files and info
### ----------------------------- ###
#
## If zsh-syntax-highlighting is installed:
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ZSH_HIGHLIGHT_MAXLENGTH=512
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
fi
## If zsh-autosuggestions is installed:
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    . /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=magenta,bold,underline"					# highlight style
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    #ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=
    ZSH_AUTOSUGGEST_BIFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    ZSH_AUTOSUGGEST_HISTORY_IGNORE=""
    ZSH_AUTOSUGGEST_COMPLETION_IGNORE="pacman -S *"
fi
## Find how many colors are supported in the current terminal (not implemented yet)
supportedcolors=$(echoti colors)
if [ "$supportedcolors" = '24' ]; then
    [[ "$COLORTERM" == (24bit|truecolor) || "${terminfo[colors]}" -eq '16777216' ]] || zmodload zsh/nearcolor
fi

### Dircolors ###
LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:';
export LS_COLORS


### ----------------------------- ###
#     Configuring $PATH
### ----------------------------- ###
# located in ~/.zshenv
#
## Example: ##
# typeset -U PATH path
# path=("$HOME/.local/bin" "$path[@]")
# export PATH


### ----------------------------- ###
#     Command Completion
### ----------------------------- ###
#
## ssh/scp/sftp hostname completion ##
autoload -Uz compinit
compinit
#
## Automatic rehash (keeps $PATH updated)
# NOTE: pacman can be configured with hooks to automatially request a rehash
# This removes the performace penalty of constantly rehashing like the command below does.
# zstyle ':completion:*' rehash true
## Autocompletion with arrow-key driver interface
# Press TAB twice to activate
zstyle ':completion:*' menu selection
#
## Autocompletion of command line switches for aliases
setopt COMPLETE_ALIASES
#
## Autocompletion of privileged environments in privileged commands
# NOTE: enabling this lets zsh completion scripts run commands as SUDO!
zstyle ':completion::complete:*' gain-privileges 1
#
# List of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' menu select=2
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro'
# the same for old style completion
#fignore=(.o .c~ .old .pro)

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'



### ----------------------------- ###
#     Key bindings
### ----------------------------- ###
# Create a zkbd compatible hash
# to add other keys to this hash, see: man 5 terminfo
bindkey -e
# bindkey '^I' complete-word # complete on tab, leave expansion to _expand
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

## Shift, Alt, Ctrl and Meta modifiers ##
# xterm-compatible terminals can use extended key-definitions for user_caps.

key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

### ----------------------------- ###
#     Functions
### ----------------------------- ###
# Set alias for ANSI color codes
## Text Type ##
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
#
## Confirm specific commands
confirm()
{
    local answer
    echo -ne "zsh: Do you want to run '$*' [yN]? "
    read -q answer
        echo
    if [[ "${answer}" =~ ^[Yy]$ ]]; then
        command "${@}"
    else
        return 1
    fi
}
#
## Confirm wrapper
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
#
## Call confirm_wrap for these commands (when typed without sudo)
poweroff() { confirm_wrap --root $0 "$@"; }
reboot() { confirm_wrap --root $0 "$@"; }
hibernate() { confirm_wrap --root $0 "$@"; }
pacman() { confirm_wrap --root $0 "$@"; }


### ----------------------------- ###
#     Prompt Configuration
### ----------------------------- ###
autoload -U colors zsh/terminfo
colors

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git*' formats "%{${fg[cyan]}%}[%{${fg[green]}%}%s%{${fg[cyan]}%}][%{${fg[blue]}%}%r/%S%%{${fg[cyan]}%}][%{${fg[blue]}%}%b%{${fg[yellow]}%}%m%u%c%{${fg[cyan]}%}]%{$reset_color%}"

## Prompt Settings ##
#
setprompt()
{
  setopt prompt_subst

  if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
    p_host='%F{red}"ssh:"%M%f'
  else
    p_host='%F{green}%M%f'
  fi

    # [username@hostname][current-directory] >
  PS1=${(j::Q)${(Z:Cn:):-$'
    %F{cyan}[%f                         ### First [
    %(!.%F{red}%n%f.%F{green}%n%f)      ### Username
    %F{cyan}@%f                         ### @
    ${p_host}                           ### Hostname
    %F{cyan}][%f                        ### ][
    %F{cyan}%d%f                        ### Current Directory
    %F{cyan}]%f                         ### Closing ]
    %(!.%F{red}" ">%f.%F{green}" ">%f)	###	Prompt
    " "
  '}}

  PS2=$'%_>'
	  # show time in HH:MM:SS on right side
  RPROMPT=' %F{white}$(date +%T)%f'
}
# Call setprompt function
setprompt
