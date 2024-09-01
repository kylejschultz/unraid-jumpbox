# Unraid Jumpbox

## Overview
A lightweight Ubuntu container used for SSHing onto an Unraid server to access only the paths mapped to the container. To be used in lieu of standard SSH or the web Console.

## Features
- Lightweight Ubuntu base image
- Zsh with Oh My Zsh and Powerlevel10k theme
- ColorLS installed for better file browsing experience.
- SSH access with GitHub SSH key integration

## Environment Variables
- `JUMP_USER`: The username for the jump user.
- `JUMP_PORT`: The port on which the SSH daemon will listen (default: 22).
- `GH_USERNAME`: The GitHub username to fetch the SSH key from.
- `GH_SSH_NAME`: The name of the SSH key to fetch from GitHub.

## Usage

### Docker Deployment
To deploy the container using Docker, you can use the following command:

```sh
docker run -d \
  --name unraid-jumpbox \
  -e JUMP_USER=your_jump_user \
  -e GH_USERNAME=your_github_username \
  -e GH_SSH_NAME=your_ssh_key_name \
  -e JUMP_PORT=22 \
  -p 22:22 \
  ghcr.io/kylejschultz/unraid-jumpbox:main
  ```

## Docker Compose Deployment
To deploy the container using Docker Compose, create a docker-compose.yml file with the following content:
```yaml
version: '3.8'
services:
  jumpbox:
    image: your_docker_image
    environment:
      - JUMP_USER=your_jump_user
      - JUMP_PUBLIC_KEY=your_public_key
      - GH_USERNAME=your_github_username
      - GH_SSH_NAME=your_ssh_key_name
      - JUMP_PORT=22
    ports:
      - "22:22"
```

Then, run the following command to start the container:
```sh
docker-compose up -d
```

## Building the Docker Image
To build the Docker image, use the following command:
docker build -t your_docker_image .

## Accessing the Container
Once the container is running, you can SSH into it using the following command:
```sh
ssh -p 22 your_jump_user@your_server_ip
```
Replace `your_jump_user`, `your_server_ip`, and `22` with the appropriate values.

