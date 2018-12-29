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
# controls whether keyring should be used for storing passwords
use-keyring=1

# controls which rdp client cli to use
rdpclient=xfreerdp

# which switch to be used to provide password and hostname to the rdp client cli
rdpclient_password_switch=p
rdpclient_hostname_switch=v

# pre and post fixes for cli switches
rdpclient_switch_prefix=/
rdpclient_switch_postfix=:

# add additional arguments to all connections
#additional_args=/f
EOF
    fi
}

# cfg_get <section> <variable> prints the variable's value
function cfg-get {    
    # when you forget how you did this:
    # https://stackoverflow.com/questions/3717772/regex-grep-for-multi-line-search-needed
    # https://unix.stackexchange.com/questions/13466/can-grep-output-only-specified-groupings-that-match
    # because -z replaces $ with \0 and bash warns when it is on the string, delete it with tr
    grep -Poz '(?s).*?\['$1'\].*?'$2'=\K\N*' $CONFIG_PATH | tr -d '\0'
}

# cfg_read_section <section>
# reads all lines under the <section> and returns a string in the format
# [key_0]="value_0" ... [key_n]="value_n"
function cfg-read-section {    
    grep -Poz '(?s).*?\['$1'\]\n\K.*?(?=$|\[)' $CONFIG_PATH |    # greps all lines under section $1 as a single string
        tr '\0' '\n' | grep -v '^\s*$' |                         # convert to non empty lines
        sed 's/\$/\\$/' |                                        # repalce $ with \$ so we can do variable expansion later
        grep -v '#' |                                            # skip comments
        sed 's/\([^=]\+\)=\?\(.*\)$/[\1]="\2"/' | tr '\n' ' '    # puts it back on a single string on the associate array format
}

# reads the name of sections
# return a string space separated of section names
# you can later call other cfg- function passing each section name
# to get more details
function cfg-read-section-names {
    grep -o '^\[.*\]' $CONFIG_PATH | sed -e 's/\[\(.*\)\]/\1/' | tr '\n' ' '
}
