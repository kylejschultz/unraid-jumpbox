#!/bin/bash

# Function to delete existing users except system users
delete_existing_users() {
    # Get a list of all users except system users
    users=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd)
    for user in $users; do
        if [ "$user" != "$JUMP_USER" ]; then
            echo "Deleting user $user"
            userdel -r $user
        fi
    done
}

# Delete existing users
delete_existing_users

# Create a user entry for the jump user with a home directory and Zsh shell
if ! id "$JUMP_USER" &>/dev/null; then
    /usr/sbin/useradd -m -s /bin/zsh "$JUMP_USER"
fi

# Put the relevant Docker environment variables into a file that the auth
# helper script can read easily.
> /etc/jump-settings
echo "JUMP_USER=\"$JUMP_USER\"" >> /etc/jump-settings
echo "JUMP_PUBLIC_KEY=\"$JUMP_PUBLIC_KEY\"" >> /etc/jump-settings

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