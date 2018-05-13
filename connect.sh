function connect-get-config {
   # read general section
    declare -A "general=( $(cfg-read-section general) )"
    
    # read config for this host
    declare -A "convals=( $(cfg-read-section $1) )"

    # merge general config into connection config, general takes less precedence
    local a1="$(declare -p general)"
    local a2="$(declare -p convals)"

    # echos values in associative array format
    echo "${a1:19:${#a1}-20} ${a2:20}"
}

ACTIONS[connect]=connect
ACTIONS_HELP[connect]="connects to a remote desktop"
function connect {          
    [[ -z "$1" ]] && { echo "connect needs hostname"; exit 1;  }
   
    # get configuration
    declare -A "vals=$(connect-get-config $1)"
    
    local prefix="${vals[rdpclient_switch_prefix]}"
    local postfix="${vals[rdpclient_switch_postfix]}"
    
    # gets the hostname from config or defaults it from connect argument
    local hostnameswitch="${vals[rdpclient_hostname_switch]}"
    if [[ ! -z $hostnameswitch ]]
    then
        local hostname="${vals[hostname]}"
        [[ -z $hostname ]] && hostname="$1"
        vals[_$hostnameswitch]="$hostname"
    fi

    # gets password
    local usekeyring="${vals[use-keyring]}"
    [[ -z usekeyring ]] && usekeyring=0
    local password=
    local pwdattr="app crdp connection $1 type user"
    # if use keyring then try to get password from it
    if [[ $usekeyring -eq 1 ]]
    then
        [[ -z "$(type -t secret-tool)" ]] && { echo "cannot use keyring because secret-tool is not installed."; exit 1;  }       
        password=$(secret-tool lookup $pwdattr)
    fi

    # TODO find a way to parse args for this command instead of using global vars
    if [[ -z $password ]] || [[ $PROMPT -eq 1 ]]
    then
        echo "Connection '$1' requires a password."
        echo -n "Password:"
        read -s password
        echo

        # store password on keyring
        if [[ $usekeyring -eq 1 ]]
        then          
            echo $password | secret-tool store --label="crdp.$1.user" $pwdattr
        fi
    fi

    # set password if switch was provided
    local passwordswitch="${vals[rdpclient_password_switch]}"
    [[ -z $passwordswitch ]] || vals[_$passwordswitch]=$password    
    
    # builds the command line call
    local args=
    for key in "${!vals[@]}"
    do
        # anything that starts with _ goes directly to the input
        if [[ $key == _* ]]
        then
            val=${vals[$key]}

            # variable subistitution
            if [[ $val == \$* ]]
            then
                val=${val:1}
                val=${!val}
            fi

            [[ -z $val ]] || val="$postfix$val"

            args="$args $prefix${key:1}$val"
        fi
    done

    # get client to be used
    rdpclient="${vals[rdpclient]}"
    [[ -z $rdpclient ]] &&
        { "rdp client is not defined. Make sure you have 'rdpclient' property defined in your configuration file."; exit 1; }

    local exec_cmd="$rdpclient $args ${vals[additional_args]} $ADD_ARGS"
    
    # if prompted to show
    [[ $SHOW -eq 1 ]] && echo $exec_cmd && exit 0
    
    # runs it
    $exec_cmd
    
    # exit with error code from rdpclient
    exit $?
}

function connect-help {
    echo "usage: $0 connect <hostname> [--prompt] [--show] [--args]

Connects to the remote desktop with name <hostname>. If <hostname> is a section on the configuration file
the configuration values under that section are used to control the connect behavior.

    --prompt can be used to force prompting for passwords, if keyring is being used and the password needs to be changed.
    --show can be used to print to stdout the connection command that would be executed (passwords may be printed)
    --args can be used to pass additional arguments to the RDP client CLI

You can add <hostname> name to your $0.cfg to save your preferences for this connection.
For more details about general configuration properties, type '$0 config-help'.
"
}

ACTIONS[config-help]=config-help
ACTIONS_HELP[config-help]="shows help information for configuration file"
function config-help {
    echo "
$0 has a single configuration file (INI format) under $CONFIG_PATH
It has section called [general] that has configuration values for this program.
You may add as many new sections as you want to configure each different RDP connection you have.
All properties starting with _ (underscore) are passed directly to the RDP command after the undescore is removed.

This is an example of configuration file:

     # global configuration goes here
     [general]
     use-keyring=1
     rdpclient=xfreerdp
     rdpclient_password_switch=p
     rdpclient_hostname_switch=v
     rdpclient_switch_prefix=/
     rdpclient_switch_postfix=:
     _u=andre

     # configuration for connecting to the machine at the office
     [officepc]
     hostname=box1.example.com
     _u=lab
     _d=example
     # configures the gateway password to be the same as the password used for the connection
     _gp=\$password

     # configuration to connect to mom's pc
     [moms]
     hostname=192.168.0.5

For such configuration file, a call to:

    $0 connect officepc

Would yield this RDP call:

      xfreerdp /u:lab /v:box1.example.com /d:example /p:<PASSWORD> /gp:<PASSWORD>

<PASSWORD> will be the value that is prompted to the user (or retrieved from the keychain).

Note that the property '_gp=\$password' uses the special variable \$password. This tells $0 to use the same password on the connection
for the gateway authentication.

Note that because '_u' was redifined on the [officepc] section, it takes precedence over the value under the [general] section.

Limitations:

    * Comments must start with # and that must be the first character on the line. (Actually # anywhere in the line makes it a comment line!)
    * No space between property name and the equals (=) sign
    * Section names must be unique. Do not reuse [general].
    * Variable substitution (e.g. $password) cannot be combined with other static values on property

For more details on the available configuration values, check the configuration file.
"
}

function config-help-help {
    config-help
}
