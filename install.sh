#!/bin/bash

# Ez SSH - Easy SSH script
clear
echo "Welcome to Ez SSH! Choose an option:"
echo "1. Private SSH"
echo "2. Public SSH"

read -p "Enter your choice [1-2]: " choice

case $choice in
    1)
        # Private SSH
        echo "Setting up Private SSH..."
        
        # Check if OpenSSH is installed
        if ! command -v ssh >/dev/null 2>&1; then
            echo "OpenSSH is not installed. Installing..."
            if [ -f /etc/debian_version ]; then
                sudo apt update && sudo apt install -y openssh-server
            elif [ -f /etc/redhat-release ]; then
                sudo yum install -y openssh-server
            else
                echo "Unsupported OS. Please install OpenSSH manually."
                exit 1
            fi
        else
            echo "OpenSSH is already installed."
        fi
        
        # Get IP address
        IP=$(hostname -I | awk '{print $1}')
        USER=$(whoami)
        
        echo ""
        echo "Private SSH setup complete!"
        echo "Your SSH login info is:"
        echo "IP: $IP"
        echo "User: $USER"
        echo "Password: ********"
        echo "You can also SSH into this machine using:"
        echo "ssh $USER@$IP"
        echo "You will be prompted for your password when connecting."
        ;;
    2)
        # Public SSH
        echo "Setting up Public SSH (SSHX)..."
        
        # Install SSHX
        curl -sSf https://sshx.io/get | sh
        
        # Clear screen and run sshx
        clear
        echo "Running SSHX..."
        sshx
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
