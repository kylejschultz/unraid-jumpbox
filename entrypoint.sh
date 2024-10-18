#!/bin/bash
# Delete existing jump users only if they exist
if id "$JUMP_USER" &>/dev/null; then
    echo "Deleting user: $JUMP_USER"
    userdel -r "$JUMP_USER"
fi

# Create a user entry for the jump user with a home directory and Zsh shell
echo "Creating user: $JUMP_USER"
useradd -m -s /bin/zsh "$JUMP_USER"

# Add the user to the sudo group
usermod -aG sudo "$JUMP_USER"

# Set the user password to `*` to disable password login but keep the account active
passwd -d "$JUMP_USER"

# Fetch the SSH key from GitHub using the GH_SSH_NAME environment variable
GH_SSH_KEY_URL="https://api.github.com/users/${GH_USERNAME}/keys"
echo "Fetching SSH key from $GH_SSH_KEY_URL"
JUMP_PUBLIC_KEY=$(curl -s $GH_SSH_KEY_URL | jq -r '.[] | select(.id == '$GH_SSH_NAME') | .key')

# Debugging output
echo "entrypoint.sh executed"
echo "JUMP_USER=$JUMP_USER"
echo "GH_USERNAME=$GH_USERNAME"
echo "GH_SSH_NAME=$GH_SSH_NAME"
echo "JUMP_PUBLIC_KEY=$JUMP_PUBLIC_KEY"

# Set up P10k theme for the user
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$JUMP_USER/powerlevel10k

# Set up SSH key for the user
mkdir -p /home/$JUMP_USER/.ssh
echo "$JUMP_PUBLIC_KEY" > /home/$JUMP_USER/.ssh/authorized_keys
chown -R $JUMP_USER:$JUMP_USER /home/$JUMP_USER/.ssh
chmod 700 /home/$JUMP_USER/.ssh
chmod 600 /home/$JUMP_USER/.ssh/authorized_keys

# Copy the updated .zshrc to the user's home directory
cp /etc/skel/.zshrc /home/$JUMP_USER/.zshrc
chown $JUMP_USER:$JUMP_USER /home/$JUMP_USER/.zshrc

# Copy the updated .p10k.zsh to the user's home directory
cp /etc/skel/.p10k.zsh /home/$JUMP_USER/.p10k.zsh
chown $JUMP_USER:$JUMP_USER /home/$JUMP_USER/.p10k.zsh

# Clean up any existing bind mount, create bind mount forß /unraid with the appropriate permissions for the jump user
if mountpoint -q /home/$JUMP_USER/unraid; then
    umount /home/$JUMP_USER/unraid
    rm -rf /home/$JUMP_USER/unraid
fi
mkdir -p /home/$JUMP_USER/unraid
bindfs -u $JUMP_USER -g $JUMP_USER /unraid /home/$JUMP_USER/unraid

# Start the SSH daemon.
exec /usr/sbin/sshd -D -e -p "${JUMP_PORT:-22}"
