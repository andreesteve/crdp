##
## crdp argument parsing functions
##

function args-print-version {
    echo "$0 version $VERSION"
    exit 0
}

function args-print-help {
    if [[ $# -gt 0 ]]
    then
        # someone called help on a command
        # if action has function with same name but ending with -help, call it
        helpfunc=${1}-help
        [[ "$(type -t $helpfunc)" == "function" ]] && $helpfunc
        [[ "$(type -t $1)" == "function" ]] || { echo "$0: '$1' is not a command. See $0 help"; exit 4; }
    else
        # print all commands
        local ts="\t\t\t\t"
        echo "usage: $0 <command> [<args>]

These are the available commands:
"
        echo -e "\tCOMMAND${ts}DESCRIPTION"
        echo
        for cmd in "${!ACTIONS[@]}"
        do
            cmdhelp=${ACTIONS_HELP[$cmd]}
            echo -e "\t$cmd${ts}$cmdhelp"
        done
        echo
        echo "You can type '$0 help <command>' to get more details on how to run that command."
        echo
    fi
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
ARGS_LONGOPTIONS=prompt,args:,show

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
        --args)
            ADD_ARGS=$2
            shift 2
            ;;
        --prompt)
             PROMPT=1
             shift
             ;;
        --show)
            SHOW=1
            shift
            ;;
        
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
if [[ $# -eq 0 ]]; then
    args-print-help    
    exit 4
fi

# read command into variable and shift $1 into first argument
COMMAND="$1"
shift
