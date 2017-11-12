_CONFIG_PATH=~/.local/share/crdp.cfg
CONFIG_PATH=$(realpath $_CONFIG_PATH)
CONFIG_DIR=$(dirname $CONFIG_PATH)
VERSION=0.0.1

# ACTIONS is a map between command and function that performs that action
# ACTIONS_HELP is the help text printed when someone types help
declare -A ACTIONS
declare -A ACTIONS_HELP

# source functions
. cfg.sh
. connect.sh

# parse options and put command into $COMMAND and arguments into $*
. args.sh

# creates config file if not exists
cfg-create-file

# parses the general config section
#cfg-read-section general

# grap function that operates on that command
action=${ACTIONS[$COMMAND]}

[[ -z "$action" ]] && { echo "unknown command $COMMAND"; echo "type '$0 help' for help"; exit 5; } || $action $*

exit 0
