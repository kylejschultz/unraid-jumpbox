#!/bin/bash

for USRN in $USERS; do
  	echo "Creating user $USRN"
	useradd -m -s /usr/bin/zsh $USRN
done

exec /usr/sbin/sshd -D -e