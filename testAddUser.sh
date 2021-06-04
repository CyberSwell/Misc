#!/bin/bash

#Sorry if this script sucks. I tried my best.
#~Jameswell Zhang (THON 2022 Systems Lead)

########## DO NOT EDIT BELOW ##########
user=""
key=""
keyFile=""
helpMsg='Usage: addUser.sh -u [username] -f [keyFile]'

### Function Definitions

#Check if amount of args are correct
checkArgs(){
        [ $# == 4 ] || (echo "[-] Incorrect number of arguments supplied, quitting." && echo "$helpMsg" && return 1)
}

#Parse parameters
parseParams() {
        while [ -n "$1" ]; do # while loop starts
                case "$1" in
                        -h)     echo "$helpMsg"
                                return 1
                                ;;
                        -u)
                                user="$2"
                                shift
                                ;;
                        -f)
                                keyFile="$2"
                                shift
                                ;;
                        *)
                                echo "[-] Option $1 not recognized, quitting."
                                return 1
                                ;;
                esac
                shift
        done
}

#Move key file contents to $key variable
readKey(){
        [ -f "$keyFile" ] && key=$(cat $keyFile) && echo "[+] Successfully read key from '$keyFile'" || (echo "[-] Issue while trying to read key from file '$keyFile', quitting." && return 0)
}

#Confirm with user that choices are correct
confirm(){
        echo "User: $user"
        echo "Key:"
        echo "$key"
        read -r -p "Are these details correct? [y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY])
                return 0        #Proceed
                ;;
            *)
                return 1        #Abort
                ;;
        esac
}
#Edit /etc/security/access.conf if user does not exist already
addSecurity() {
        grep -q "$user" /etc/security/access.conf && echo "[-] User '$user' exists in access.conf, skipping this step." || (sed -i '$i'"+ : $user: ALL" /etc/security/access.conf && echo "[+] User '$user' added to /etc/security/access.conf")
}

#Make user sudoer if they are not already
addSudo() {
        grep -q "$user" /etc/sudoers.d/sudo-users && echo "[-] User '$user' already has entry in /etc/sudoers.d/sudo-users, skipping this step."|| (sed -i '$i'"$user     ALL=(ALL)       ALL" /etc/sudoers.d/sudo-users && echo "[+] User '$user' added to /etc/sudoers.d/sudo-users")
}

#Make directories
addDirectories() {
        [ -d "/home/$user/" ] && echo "[-] A home directory already exists for '$user', skipping this step." || (mkdir -p /home/$user/.ssh/ && echo "[+] Created '/home/$user/.ssh/' directory, along with necessary parent directories" || echo "[-] Issue while attempting to create directories. This is unusual.")
}

#Set up private key
addKey() {
        touch -c /home/$user/.ssh/authorized_keys && echo "[-] An authorized_keys file already exists for '$user', skipping this step." || (touch /home/$user/.ssh/authorized_keys && echo "$key" > /home/$user/.ssh/authorized_keys && echo "[+] Private key imported into /home/$user/.ssh/authorized_keys" || echo "[-] Issue while attempting to import private key")
}

#Give user access to their home directory
buyHouse() {
        [ "$user" == "$(ls -ld /home/$user/ | awk '{print $3}')" ] && echo "[-] User '$user' already owns /home/$user/', skipping this step." || (chown -R $user:access /home/$username || echo "[-] Issue while attempting to grant access to home directory for '$user'")
}

#### MAIN METHOD
echo "Beginning SSH configuration for "$HOSTNAME"..."
checkArgs "$@" && parseParams "$@" || exit 1
readKey || exit 1
confirm && addSecurity && addSudo && addDirectories && addKey && buyHouse || exit 1
echo "[+] User and key successfully added! To log in, please use the following command:"
echo "ssh -i [priv_key] -p [port] "$user"@"$HOSTNAME""
exit 0
