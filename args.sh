##
## crdp argument parsing functions
##

function args-print-version {
    echo "$0 version $VERSION"
    exit 0
}

function args-print-help {
    echo "usage: $0 <command> [<args>]"
    echo -e "\tCOMMAND\t\t\t\tDESCRIPTION"
    for cmd in "${!ACTIONS[@]}"
    do
        cmdhelp=${ACTIONS_HELP[$cmd]}
        echo -e "\t$cmd\t\t\t\t$cmdhelp"
    done
}

# register actions provided by this file
ACTIONS[help]=args-print-help
ACTIONS_HELP[help]="prints this help message"
ACTIONS[version]=args-print-version
ACTIONS_HELP[version]="prints the version string"

# below is mostly a blatant copy of https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    echo "You need getopt installed to use crdp. `getopt --test` failed."
    exit 1
fi

# using : means that option has a value (e.g. --verbosity 2)
ARGS_OPTIONS=
ARGS_LONGOPTIONS=

# -temporarily store output to be able to check for errors
# -e.g. use “--options” parameter by name to activate quoting/enhanced mode
# -pass arguments only via   -- "$@"   to separate them correctly
ARGS_PARSED=$(getopt --options=$ARGS_OPTIONS --longoptions=$ARGS_LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi

# read getopt’s output this way to handle the quoting right:
eval set -- "$ARGS_PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        # -d|--debug)
        #     d=y
        #     shift
        #     ;;
        # -f|--force)
        #     f=y
        #     shift
        #     ;;
        # -v|--verbose)
        #     v=y
        #     shift
        #     ;;
        # -o|--output)
        #     outFile="$2"
        #     shift 2
        #     ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

# handle non-option arguments
if [[ $# -ne 1 ]]; then
    args-print-help    
    exit 4
fi

# read command into variable and shift $1 into first argument
COMMAND="$1"
shift
