_CONFIG_PATH=~/.local/share/crdp.cfg
CONFIG_PATH=$(realpath $_CONFIG_PATH)
CONFIG_DIR=$(dirname $CONFIG_PATH)
VERSION=0.0.1

# resolve symlinks
# from https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# ACTIONS is a map between command and function that performs that action
# ACTIONS_HELP is the help text printed when someone types help
declare -A ACTIONS
declare -A ACTIONS_HELP

# source functions
. $DIR/cfg.sh
. $DIR/connect.sh
. $DIR/list.sh

# parse options and put command into $COMMAND and arguments into $*
. $DIR/args.sh

# creates config file if not exists
cfg-create-file

# parses the general config section
#cfg-read-section general

# grap function that operates on that command
action=${ACTIONS[$COMMAND]}

[[ -z "$action" ]] && { echo "unknown command $COMMAND"; echo "type '$0 help' for help"; exit 5; } || $action $*

exit 0
