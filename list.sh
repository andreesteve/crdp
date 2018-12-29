ACTIONS[list]=list
ACTIONS_HELP[list]="list remote desktop connections"
function list {
   # read all section names
    secnames=("$(cfg-read-section-names)")
    
    for name in $secnames
    do
        echo $name
    done
}

function list-help {
    echo "usage: $0 list

    Lists the configured connections.
"
}
