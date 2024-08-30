# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Configure APT to not install suggested or recommended packages
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

# Copy the ssh-user-auth.sh and entrypoint.sh scripts to /usr/bin/
COPY ssh-user-auth.sh /usr/bin/ssh-user-auth.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh

# Update package list and install necessary packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt update \
    && apt install -y python3 ruby zsh git vim zsh-autosuggestions zsh-syntax-highlighting curl openssh-server netcat telnet \
    && rm -rf /var/lib/apt/lists/* \
    && chmod 755 /usr/bin/ssh-user-auth.sh \
    && chmod 755 /usr/bin/entrypoint.sh

# Install Oh My Zsh
RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# Configure Zsh to use syntax highlighting and autosuggestions plugins
RUN echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc && \
    echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

# Create the /run/sshd directory required by the SSH daemon
RUN mkdir -p /run/sshd

# Expose port 22 for SSH
EXPOSE 22

# Set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["/usr/bin/entrypoint.sh"]