#!/bin/bash

date=$(date '+%Y-%m-%d')

echo -e "\nBackup /etc/tor/torrc to /etc/tor/torrc.$date\n"
cp -f /etc/tor/torrc /etc/tor/torrc.$date

#Checks for the string 'ator' in ContactInfo
if grep -qi 'ContactInfo.*@ator' /etc/tor/torrc; then
    echo -e "The string '@ator' was found in a ContactInfo line.. removing now.. Reminder to verify mail address!\n"
fi

#Checks for the string 'ator' in Nickname
if grep -qi 'Nickname.*ator' /etc/tor/torrc; then
    echo -e "The string 'ator' was found in a Nickname line.. removing now..\n"
fi

# Removes word "ator" from Nickname line and removes @ator: and following wallet value
sed -i -e '/ContactInfo/s/@ator:.*//I' -e '/Nickname/s/ator//Ig' -e '/ContactInfo/s/ator//Ig' /etc/tor/torrc

# Directories to be renamed
directories=("/var/lib/tor/keys" "/var/db/tor/keys" "/var/tor/keys")

# Loop through each directory
for dir in "${directories[@]}"; do
    # Check if directory exists and keys.old does not exist
    if [ -d "$dir" ] && [ ! -d "${dir}.old" ]; then
        mv "$dir" "${dir}.old"
    fi
done

echo "Renewing fingerprint. Installing ATOR relay patch, stand by for the service to restart.."

# Restarts tor service
systemctl restart tor