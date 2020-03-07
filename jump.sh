#!/bin/bash

function usage() {
    echo
    echo "Usage: `basename $0` [-a|-l <group>|-c <host>]"
  	echo
  	echo "    -a         Show all hosts"
  	echo "    -l <group> List the hosts in this group"
  	echo "    -c <host>  Connect this host directly"
  	echo "    -h         Show this help text."
  	echo
}

function parse_ini() {
    eval $(awk -F= '
        {
            if ($1 ~ /^\[/) {
                section=tolower(gensub(/\[(.+)\]/, "\\1", 1, $1))
            } else if ($1 !~ /^$/ && $1 !~ /^;/) {
                gsub(/^[ \t]+|[ \t]+$/, "", $1); 
                gsub(/[\[\]]/, "", $1);
                gsub(/^[ \t]+|[ \t]+$/, "", $2); 
                if (globals[section][$1] == "")  {
                    globals[section][$1]=$2
                } else {
                    globals[section][$1]=globals[section][$1]","$2
                }
            } 
        }
        END {
            for (section in globals) {
                for (key in globals[section])  {
                    print "globals_"section"_"key"=\""globals[section][key]"\";"
                }
                if (section ~ /^group/) {
                    gsub(/,/, ","substr(section, 7)":", globals[section]["hosts"])
                    if (all_hosts == "") {
                        all_hosts=substr(section, 7)":"globals[section]["hosts"]
                    } else {
                        all_hosts=all_hosts","substr(section, 7)":"globals[section]["hosts"]
                    }
                }
            }
            print "globals_all_hosts=\""all_hosts"\";"
        }' $1
    )
}

function load() {
    if [ -e "${PWD}/hosts.ini" ]; then
        rcfile="${PWD}/hosts.ini"
    elif [ -e "${HOME}/.jump/hosts.ini" ]; then
        rcfile="${HOME}/.jump/hosts.ini"
    elif [ -e "/etc/jump/hosts.ini" ]; then
        rcfile="/etc/jump/hosts.ini"
    else
        echo "Configure Not Found"
    fi
    parse_ini $rcfile
}

function connect() {
    jumper=${globals_default_jumper}
    private=${globals_default_private}
    user=${globals_default_user}
    port=${globals_default_port}
    if [[ $1 != "default" ]]; then
        if [[ $(eval echo \$"globals_group_$1_jumper") != "" ]]; then
            jumper=$(eval echo \$"globals_group_$1_jumper")
        fi
        if [[ $(eval echo \$"globals_group_$1_private") != "" ]]; then
            private=$(eval echo \$"globals_group_$1_private")
        fi
        if [[ $(eval echo \$"globals_group_$1_user") != "" ]]; then
            user=$(eval echo \$"globals_group_$1_user")
        fi
        if [[ $(eval echo \$"globals_group_$1_port") != "" ]]; then
            port=$(eval echo \$"globals_group_$1_port")
        fi
    fi
    if [[ $2 == "jumper" ]]; then
        if [[ ${jumper} != "None" ]]; then
            ssh -i ${private} -l ${user} -p ${port} ${jumper}
        else
            echo "Jumper Not Found"
        fi
    else
        if [[ ${jumper} != "None" ]]; then
            proxy="ProxyCommand ssh -i ${private} -l ${user} -p ${port} ${jumper} -W %h:%p"
            ssh -i ${private} -l ${user} -p ${port} -o "${proxy}" $2
        else
            ssh -i ${private} -l ${user} -p ${port} $2
        fi
    fi
}

function list() {
    PS3="=> Where to jump via jumper? "
    echo
    if [[ "$1" == "all" ]]; then
        hstr=${globals_all_hosts}
        hstr="quit,jumper,$hstr"
        harr=(${hstr//,/ })
        select item in "${harr[@]}"
        do
            case ${item} in
                quit)
                    break
                    ;;
                jumper)
                    connect "default" "jumper"
                    break
                    ;;
                *)
                    arr=(${item//:/ })
                    connect ${arr[0]} ${arr[1]}
                    break
                    ;;
            esac
        done
    else
        hstr=$(eval echo \$"globals_group_$1_hosts")
        if [[ "${hstr}" != "" ]]; then
            hstr="quit,jumper,$hstr"
            harr=(${hstr//,/ })
            select host in "${harr[@]}"
            do
                echo $host
                case $host in
                    quit)
                        exit 0
                        ;;
                    *)
                        connect $1 $host
                        break
                        ;;
                esac
            done            
        else
            echo "Group Not Found: $1"
            exit 3
        fi
    fi
}

load

while getopts ":al:c:h" arg
do
    case $arg in
        a)
            list "all"
            exit 0
            ;;
        l)
            list $OPTARG
            exit 0
            ;;
        c)
            connect $OPTARG
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done