# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Configure APT to not install suggested or recommended packages
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

# Update packages and install jump box dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q update
RUN apt-get install -y --no-install-recommends \
    python3 \
    ruby \
    zsh \
    git \
    vim \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    curl \
    openssh-server \
    netcat \
    telnet \
    nano
RUN mkdir /var/run/sshd

#  Cleanup after Apt to slim down image.
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Only keys can be used to authenticate.
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
# No user-specific key files are checked.
RUN echo "AuthorizedKeysFile none" >> /etc/ssh/sshd_config

# Call script for authentication.
RUN echo "AuthorizedKeysCommand /usr/bin/ssh-user-auth.sh" >> /etc/ssh/sshd_config \
RUN echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config \
# Allow user to setup tunnels
RUN echo "GatewayPorts yes" >> /etc/ssh/sshd_config

# Install Oh My Zsh
RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# Install Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/oh-my-zsh/custom/themes/powerlevel10k

# Configure Zsh to use syntax highlighting and autosuggestions plugins
RUN echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /etc/skel/.zshrc && \
    echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /etc/skel/.zshrc && \
    echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> /etc/skel/.zshrc

# Install our custom scripts.
COPY ssh-user-auth.sh /ssh-user-auth.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /ssh-user-auth.sh /entrypoint.sh

# Set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["/entrypoint.sh"]