# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k Configuration
source ~/powerlevel10k/powerlevel10k.zsh-theme

# ColorLS
source $(dirname $(gem which colorls))/tab_complete.sh
alias lc='colorls -lA --sd'

# Misc Env Stuff
alias loadzsh='source ~/.zshrc && echo "Reloaded"'

#############################
### History Configuration ###
#############################
HISTSIZE=5000           #How many lines of history to keep in memory
HISTFILE=~/.zsh_history #Where to save history to disk
SAVEHIST=25000          #Number of history entries to save to disk
#HISTDUP=erase               #Erase duplicates in the history file
setopt appendhistory    #Append history to the history file (no overwriting)
setopt sharehistory     #Share history across terminals
setopt incappendhistory #Immediately append to the history file, not just when a term is killed

alias hh=hstr                         # hh to be alias for hstr
setopt histignorespace                # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor            # get more colors
bindkey -s "\C-r" "\C-a hstr -- \C-j" # bind hstr to Ctrl-r (for Vi mode check doc)
export HSTR_TIOCSTI=y

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh