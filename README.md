# crdp - a CLI for RDP clients

crdp is a Bash 4 program that wraps RDP a CLI client like [freerdp](https://github.com/FreeRDP/FreeRDP), manages RDP connections
and integrates with keyrings for storing passwords.

## Features

* Integrated with *secret-tool* for password-less connection
* Keep your connection configuration organized in a file

## Example

On a configuration file, you keep your connection and their configuration:

```
# configuration to connect to the office
[office]
hostname=box1.example.com
_u=lab
_d=example

# configuration to connect to mom's pc
[moms]
hostname=192.168.0.5
```

Then you can connect by calling:

```
crdp connect office
```

If keyring integration is enabled, you will only need to provide password on the first time you connect.

## Usage

```
usage: crdp <command> [<args>]

These are the available commands:

	COMMAND				DESCRIPTION

	version				prints the version string
	help				prints this help message
	connect				connects to a remote desktop
	config-help			shows help information for configuration file

You can type 'crdp help <command>' to get more details on how to run that command.
```

## Installation

Clone this repo into a folder, enable execution of the script file and add it to your path.

```
$ git clone https://github.com/andreesteve/crdp.git ~/bin/crdp
$ chmod +x ~/bin/crdp/crdp
$ export PATH=$PATH:~/bin/crdp
```

Call any of the help command and crdp will initialize the base configuration automatically.

```
$ crdp help config-help
```

Open the configuration file *~/.local/share/crdp.cfg* and add one section for each RDP you want to use.
For example:

```
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

# all values under the general section applies to all connections
# add additional arguments to all connections
additional_args=/f /sound:sys:alsa,format:1,quality:high /microphone:sys:alsa,format:1,quality:high /home-drive +clipboard /multimon /monitors:0,2

[office]
hostname=office.example.com
_u=andre-office
_d=mydomain
_gp=$password
_g:mygateway.example.com
_gu=andre

[home]
hostname=192.168.0.100
_u=andre
```

Connect to the desired RDP by:

```
$ crdp connect office
# or
$ crdp connect home
```

## Documentation

crdp has a single configuration file (INI format) under 
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
     _gp=$password

     # configuration to connect to mom's pc
     [moms]
     hostname=192.168.0.5

For such configuration file, a call to:

    crdp connect officepc

Would yield this RDP call:

      xfreerdp /u:lab /v:box1.example.com /d:example /p:<PASSWORD> /gp:<PASSWORD>

<PASSWORD> will be the value that is prompted to the user (or retrieved from the keychain).

Note that the property '_gp=$password' uses the special variable $password. This tells crdp to use the same password on the connection
for the gateway authentication.

Note that because '_u' was redifined on the [officepc] section, it takes precedence over the value under the [general] section.

Limitations:

    * Comments must start with # and that must be the first character on the line. (Actually # anywhere in the line makes it a comment line!)
    * No space between property name and the equals (=) sign
    * Section names must be unique. Do not reuse [general].
    * Variable substitution (e.g. ) cannot be combined with other static values on property

For more details on the available configuration values, check the configuration file.
