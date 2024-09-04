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
        nano \
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
        jq \
        hstr \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && chmod 755 /usr/bin/ssh-user-auth.sh \
    && chmod 755 /usr/bin/entrypoint.sh

# Configure SSH to use the ssh-user-auth.sh script for authorized keys
RUN sed -i 's/^UsePAM yes/#UsePAM yes/' /etc/ssh/sshd_config \
    && echo "AuthorizedKeysCommand /usr/bin/ssh-user-auth.sh" >> /etc/ssh/sshd_config \
    && echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
    && echo "UsePAM no" >> /etc/ssh/sshd_config

# Install locales package and set locale
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Set environment variables for locale
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Copy the custom .zshrc file into the image and apply it as default for new users
COPY .zshrc /tmp/.zshrc
RUN cat /tmp/.zshrc >> /etc/skel/.zshrc \
    && rm /tmp/.zshrc

# Copy P10k config to default template
COPY .p10k.zsh /tmp/.p10k.zsh
RUN cat /tmp/.p10k.zsh >> /etc/skel/.p10k.zsh \
    && rm /tmp/.p10k.zsh

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Powerlevel10k theme
RUN git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Download and Install Font
RUN curl -Lo /tmp/font.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip" \
    && unzip /tmp/font.zip -d /usr/share/fonts \
    && fc-cache -fv \
    && rm /tmp/font.zip

# install colorls
RUN gem install colorls

# Create the /run/sshd directory required by the SSH daemon
RUN mkdir -p /run/sshd

# Expose port 22 for SSH
EXPOSE ${JUMP_PORT:-22}

# Set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["/usr/bin/entrypoint.sh"]