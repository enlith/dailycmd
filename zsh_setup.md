link: https://fai555.medium.com/improved-terminal-for-maximum-productivity-ced03cb5c0ef

# replace ls
brew install exa

# pretty json and yaml printer
brew install yq

# terimnal based file manager
brew install ranger

## { fzf setup
git clone --depth 1 https://github.com/junegunn/fzf.git  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/fzf


${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/fzf/install
brew install fd

### { add below to .zshrc
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPS="--extended"
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


### } add below to .zshrc


#search history by ctrl + r

# search through files on current folder by ctrl + t
# use key "tab" to mark choice

## } fzf setup
