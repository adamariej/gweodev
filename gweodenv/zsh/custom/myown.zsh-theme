#local blink_red="%{$(printf '\033[31;5m]')}"
local ret_status="%(?:%{$fg_bold[blue]%}:%{$fg_bold[red]%})▶ "
#local root_status="%(#:${blink_red}(Root):$fg[default]) "

PROMPT='%{$fg_bold[blue]%}┌─%{$reset_color%}%{$fg[green]%}${SSH_CONNECTION+"%{$fg[red]%}"}%m $(git_prompt_info) %{$fg_bold[white]%}%~
%{$fg_bold[blue]%}└─${ret_status}${root_status}%{$reset_color%}'

PS2=$' \e[0;34m%}%B>%{\e[0m%}%b '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(git:%{$fg_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[blue]%})%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} ✗ "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[red]%}"
 ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"

