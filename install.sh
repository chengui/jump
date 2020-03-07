#!/bin/bash

if [ -L "$HOME/.jump/hosts.ini" ]; then
	rm -rf $HOME/.jump/hosts.ini
	ln -s -f $(cd `dirname $0`; pwd)/hosts.ini $HOME/.jump/hosts.ini
fi
if [ -L "/usr/local/bin/jump" ]; then
	rm -rf /usr/local/bin/jump
	ln -s -f $(cd `dirname $0`; pwd)/jump.sh /usr/local/bin/jump
fi