# Base Image
FROM ubuntu:24.04

# APT Configuration
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

# Copy Scripts
COPY ssh-user-auth.sh /usr/bin/ssh-user-auth.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh

# Install Packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt update \
    && apt install -y python3 \
        ruby \
        zsh \
        git \
        vim \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        curl \
        openssh-server \
        telnet \
        ruby-dev \
        libc6-dev \
        gcc \
        make \
        unzip \
        fontconfig \
    && rm -rf /var/lib/apt/lists/* \
    && chmod 755 /usr/bin/ssh-user-auth.sh \
    && chmod 755 /usr/bin/entrypoint.sh

# Configure SSH to use the ssh-user-auth.sh script for authorized keys
RUN sed -i 's/^UsePAM yes/#UsePAM yes/' /etc/ssh/sshd_config \
    && echo "AuthorizedKeysCommand /usr/bin/ssh-user-auth.sh" >> /etc/ssh/sshd_config \
    && echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
    && echo "UsePAM yes" >> /etc/ssh/sshd_config

# Install Oh My Zsh
RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# Install Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/oh-my-zsh/custom/themes/powerlevel10k

# Download and Install Font
RUN curl -Lo /tmp/font.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip" \
    && unzip /tmp/font.zip -d /usr/share/fonts \
    && fc-cache -fv \
    && rm /tmp/font.zip

# install colorls
RUN gem install colorls

# Configure Zsh to use syntax highlighting, autosuggestions plugins, and Powerlevel10k theme
RUN echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /etc/skel/.zshrc \
    && echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /etc/skel/.zshrc \
    && echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> /etc/skel/.zshrc \
    && echo "source $(dirname $(gem which colorls))/tab_complete.sh" >> /etc/skel/.zshrc \
    && echo "alias lc='colorls -A --sd'" >> /etc/skel/.zshrc

# Create the /run/sshd directory required by the SSH daemon
RUN mkdir -p /run/sshd

# Expose port 22 for SSH
EXPOSE ${JUMP_PORT:-22}

# Set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["/usr/bin/entrypoint.sh"]