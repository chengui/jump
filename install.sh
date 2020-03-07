#!/bin/bash

rm -rf /usr/local/bin/jump
rm -rf $HOME/.jump/hosts.ini
ln -s -f $(cd `dirname $0`; pwd)/jump.sh /usr/local/bin/jump
ln -s -f $(cd `dirname $0`; pwd)/hosts.ini $HOME/.jump/hosts.ini