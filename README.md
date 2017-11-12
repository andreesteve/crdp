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
