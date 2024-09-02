#!/bin/bash
# Delete existing jump users
echo "Deleting users: $JUMP_USER"
userdel -r $JUMP_USER

# Create a user entry for the jump user with a home directory and Zsh shell
if ! id "$JUMP_USER" &>/dev/null; then
    /usr/sbin/useradd -m -s /bin/zsh "$JUMP_USER"
fi

# Unlock the user account if it is locked
passwd -u "$JUMP_USER"

# Fetch the SSH key from GitHub using the GH_SSH_NAME environment variable
GH_SSH_KEY_URL="https://api.github.com/users/${GH_USERNAME}/keys"
echo "Fetching SSH key from $GH_SSH_KEY_URL"
JUMP_PUBLIC_KEY=$(curl -s $GH_SSH_KEY_URL | jq -r '.[] | select(.id == '$GH_SSH_NAME') | .key')
echo "Filtered key: $JUMP_PUBLIC_KEY"

# Debugging output
echo "entrypoint.sh executed"
echo "JUMP_USER=$JUMP_USER"
echo "GH_USERNAME=$GH_USERNAME"
echo "GH_SSH_NAME=$GH_SSH_NAME"
echo "JUMP_PUBLIC_KEY=$JUMP_PUBLIC_KEY"

# Set up SSH key for the user
mkdir -p /home/$JUMP_USER/.ssh
echo "$JUMP_PUBLIC_KEY" > /home/$JUMP_USER/.ssh/authorized_keys
chown -R $JUMP_USER:$JUMP_USER /home/$JUMP_USER/.ssh
chmod 700 /home/$JUMP_USER/.ssh
chmod 600 /home/$JUMP_USER/.ssh/authorized_keys

# Copy the updated .zshrc to the user's home directory
cp /etc/skel/.zshrc /home/$JUMP_USER/.zshrc
chown $JUMP_USER:$JUMP_USER /home/$JUMP_USER/.zshrc

# Start the SSH daemon.
exec /usr/sbin/sshd -D -e -p "${JUMP_PORT:-22}"