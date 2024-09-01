#!/bin/bash

# Load the settings, which come from Docker environment variables originally.
. /etc/jump-settings

# Debugging output
echo "ssh-user-auth.sh executed"
echo "JUMP_USER=$JUMP_USER"
echo "JUMP_PUBLIC_KEY=$JUMP_PUBLIC_KEY"
echo "SSH_USER=$1"

# If the user is the one and only jump user, then return the one and only
# public key. If the authentication attempt is using a corresponding private
# key, the authentication attempt will succeed.
if [ "$1" == "$JUMP_USER" ]; then
  echo "$JUMP_PUBLIC_KEY"
  echo "Returning public key for $JUMP_USER"
else
  echo "No matching user found"
fi