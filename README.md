# jump

## Introduction

`jump` is a command line utility which allow you to ssh any host via jumper.

## Installation

- Git clone the source
    ```bash
    $ git clone https://github.com/chengui/jump.git ~/.jump
    ```
- Create symbolic link
    ```bash
    $ chmod +x $HOME/.jump/jump.sh
    $ ln -s -f $HOME/.jump/jump.sh /usr/local/bin/jump
    ```

## Usage

```shell
Usage: jump [-a|-l <group>|-c <host>]

    -a         Show all hosts
    -l <group> List the hosts in this group
    -c <host>  Connect this host directly
    -h         Show this help text.

```

## Configuration

The configuration file is naming as `hosts.ini`, and `jump` would search in order: `${PWD}/hosts.ini` > `${HOME}/.jump/hosts.ini` > `/etc/jump/hosts.ini`. It looks like:

```ini
[default]
private=~/.ssh/id_rsa
jumper=jumper.abc.com
user=chengui
port=22

[group_master]
hosts=10.1.1.1,10.1.2.1,10.1.3.1

[group_worker]
hosts=10.1.1.10,10.1.2.10,10.1.3.10

[group_local]
private=~/.ssh/id_dsa
jumper=None
user=vagrant
port=22
hosts=192.168.99.100
```