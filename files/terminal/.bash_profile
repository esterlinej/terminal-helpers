### KUBE CONFIG ###########################################

KUBECONFIG=~/.kube/cluster-merge:~/.kube/config
for file in ~/.kube/*.config; do
	KUBECONFIG="$KUBECONFIG:$file"
done
export KUBECONFIG

### HOMEBREW ##############################################
PATH=/usr/local/bin:$PATH
PATH=$HOME/bin:$PATH
export PATH
export CLICOLOR=1
export TERM=xterm-256color

### SOURCE FILES TO PATH ##################################
# run this manually with `$ src` from the terminal
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra,profile,bash_profile,bashrc,func_acyl,func_kubernetes,func_vault,func_github,func_terraform}; do
		[ -r "$file" ] && source "$file"
	done
	# cleanup path, remove duplicates
	export PATH=$(echo $PATH | awk -F: '
		{ for (i = 1; i <= NF; i++) arr[$i]; }
		END { for (i in arr) printf "%s:" , i; printf "\n"; } ')

### RUBY VERSION MANAGER ##################################
# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

### PYTHON VERSION PATHS ##################################
# Setting PATH for Python 2.7
export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"

# Setting PATH for Python 3.7
#export PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"

# Setting PATH for Python 3.8
# export PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin:${PATH}"

# Setting PATH for Python 3.9
export PATH="/Library/Frameworks/Python.framework/Versions/3.9/bin:${PATH}"
