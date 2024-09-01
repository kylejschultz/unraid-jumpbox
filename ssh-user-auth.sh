#!/bin/bash

# Load the settings, which come from Docker environment variables originally.
. /etc/jump-settings

# Debugging output
echo "ssh-user-auth.sh executed" >> /var/log/ssh-user-auth.log
echo "JUMP_USER=$JUMP_USER" >> /var/log/ssh-user-auth.log
echo "JUMP_PUBLIC_KEY=$JUMP_PUBLIC_KEY" >> /var/log/ssh-user-auth.log
echo "SSH_USER=$1" >> /var/log/ssh-user-auth.log

# If the user is the one and only jump user, then return the one and only
# public key. If the authentication attempt is using a corresponding private
# key, the authentication attempt will succeed.
if [ "$1" == "$JUMP_USER" ]; then
  echo "$JUMP_PUBLIC_KEY"
  echo "Returning public key for $JUMP_USER" >> /var/log/ssh-user-auth.log
else
  echo "No matching user found" >> /var/log/ssh-user-auth.log
fi