#!/bin/bash

# Load the settings, which come from Docker environment variables originally.
. /etc/jump-settings

# If the user is the one and only jump user, then return the one and only
# public key.  If the authentication attempt is using a corresponding private
# key, the authentication attempt will succeed.
if [ "$1" == "$JUMP_USER" ]; then
  echo "$JUMP_PUBLIC_KEY"
fi