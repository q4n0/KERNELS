#!/bin/bash

set -e  # Exit script immediately on non-zero exit codes

echo "This script automates the installation of a mainline Linux kernel from the Zabbly PPA on Debian-based distributions (excluding Ubuntu and Debian themselves)."
echo "**Important:**"
echo "* Proceed with caution! Installing a mainline kernel can potentially introduce instability on your system. Thoroughly research and understand the risks involved before running the script."
echo "* This script prioritizes safety. If you're not using a Debian-based system, it's highly recommended to use official kernel installation methods provided by your distribution."

# Detect OS using os-release file (if available)
if [ -f /etc/os-release ]; then
  source /etc/os-release
  if [[ ! "$ID" == "debian" ]]; then
    echo "**Warning:** You are not using a Debian-based system. This script is designed for Debian and might not work correctly on your distribution. Consider using official kernel installation methods provided by your distribution manager to avoid potential issues."
    read -p "Press Enter to continue at your own risk (or Ctrl+C to abort): "
  fi
fi

# Update system packages
apt update || echo "Failed to update package lists. Check your internet connection or repositories."

# Install necessary tools
apt -y install git wget curl || echo "Failed to install necessary tools (git, wget, curl). Check package availability on your system."

# Package cleanup (optional)
apt autoremove -y || echo "Failed to remove unnecessary packages."

# Zabbly PPA Setup (verify fingerprint before proceeding!)

# Download key
echo "Downloading Zabbly PPA key..."
sudo curl -fsSL https://pkgs.zabbly.com/key.asc > /tmp/zabbly.asc || (echo "Failed to download Zabbly PPA key. Check the URL or your internet connection." ; exit 1)

# Verify fingerprint
echo "Verifying key fingerprint..."
gpg --show-keys --fingerprint /tmp/zabbly.asc
echo "**Important:**"
echo "Compare the fingerprint above with the official Zabbly documentation or a trusted source. If they don't match, DO NOT proceed further."
read -p "Press Enter to continue verification (or Ctrl+C to abort): "

# Import key if verification passes
sudo mv /tmp/zabbly.asc /etc/apt/keyrings/zabbly.asc || echo "Failed to move downloaded key to its designated location."

# Create PPA source file (default to Debian suite)
echo "Creating PPA source file..."
suite="bookworm"  # Replace with your desired default release if applicable

sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-kernel-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/kernel/stable
Suites: '"$suite"'  # Use default suite
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF' || echo "Failed to create PPA source file."

# Update package list with new PPA
apt update || echo "Failed to update package list after adding PPA."

# Install mainline kernel package
echo "Installing mainline kernel package..."
apt-get install -y linux-zabbly || echo "Failed to install mainline kernel package. Check availability on the PPA or consider a different kernel version."

# Final system updates and cleanup
apt upgrade -y || echo "Failed to perform final system upgrades."
apt autoremove -y || echo "Failed to remove unnecessary packages after installation."

# Update bootloader configuration
update-grub || echo "Failed to update bootloader configuration. Reboot might be required manually."

# Reboot the system (to apply changes)
echo "The script has finished. Your system will now reboot to apply the new kernel."
read -p "Press Enter to reboot (or Ctrl+C to postpone): "
reboot || echo "Failed to reboot the system. You might need to reboot manually."
