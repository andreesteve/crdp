##
## crp configuration related functions
##

function cfg-create-file {
    # creates config dir if not exists
    [[ -d $CONFIG_DIR  ]] || mkdir -p $CONFIG_DIR
    
    # creates config file if not exists
    if [[ ! -f $CONFIG_PATH ]]
    then
        echo $1 
        cat > "$CONFIG_PATH" <<EOF
[general]
use_secret_tool=1
EOF
    fi
}

# cfg_get <section> <variable> prints the variable's value
# cfg_get <secion> reads all variable lines under <section> and prefix them with cfg_<section>_
function cfg-get {    
    # when you forget how you did this:
    # https://stackoverflow.com/questions/3717772/regex-grep-for-multi-line-search-needed
    # https://unix.stackexchange.com/questions/13466/can-grep-output-only-specified-groupings-that-match
    # because -z replaces $ with \0 and bash warns when it is on the string, delete it with tr
    [[ ! -z $2 ]] && grep -Poz '(?s).*?\['$1'\].*?'$2'=\K\N*' $CONFIG_PATH | tr -d '\0' \
            || grep -Poz '(?s).*?\['$1'\]\n\K.*?(?=$|\[)' $CONFIG_PATH | tr '\0' '\n' | grep '=' | sed 's/^\(.*\)$/cfg_'$1'_\1/'
}

# cfg_read_section <section>
# populate variables cfg_<section>_<varname> with variable values
function cfg-read-section {
    local vals=$(cfg-get $1)
    # eval will byte me later, this needs fixing
    eval "$vals"
}
