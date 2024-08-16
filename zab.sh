#!/bin/bash

set -e  # Exit script immediately on non-zero exit codes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}*********************************************${NC}"
echo -e "${GREEN}***      b0urn3's Kernel Install Script    ***${NC}"
echo -e "${GREEN}***  GitHub: https://github.com/q4n0      ***${NC}"
echo -e "${BLUE}*********************************************${NC}"

echo -e "${YELLOW}This script automates the installation of a mainline Linux kernel from the Zabbly PPA on Debian-based distributions (excluding Ubuntu and Debian themselves).${NC}"
echo -e "${RED}**Important:**${NC}"
echo -e "${RED}* Proceed with caution! Installing a mainline kernel can potentially introduce instability on your system. Thoroughly research and understand the risks involved before running the script.${NC}"
echo -e "${RED}* This script prioritizes safety. If you're not using a Debian-based system, it's highly recommended to use official kernel installation methods provided by your distribution.${NC}"

# Detect OS using os-release file (if available)
if [ -f /etc/os-release ]; then
  source /etc/os-release
  if [[ ! "$ID" == "debian" ]]; then
    echo -e "${RED}**Warning:** You are not using a Debian-based system. This script is designed for Debian and might not work correctly on your distribution. Consider using official kernel installation methods provided by your distribution manager to avoid potential issues.${NC}"
    read -p "Press Enter to continue at your own risk (or Ctrl+C to abort): "
  fi
else
  echo -e "${RED}No /etc/os-release file found. Unable to determine the OS distribution.${NC}"
  exit 1
fi

# Ensure `gpg` is installed
if ! command -v gpg &> /dev/null; then
  echo -e "${YELLOW}GPG is not installed. Installing...${NC}"
  apt-get update
  apt-get install -y gnupg || { echo -e "${RED}Failed to install GPG. Exiting.${NC}"; exit 1; }
fi

# Update system packages
echo -e "${YELLOW}Updating system packages...${NC}"
apt update || { echo -e "${RED}Failed to update package lists. Check your internet connection or repositories.${NC}"; exit 1; }

# Install necessary tools
echo -e "${YELLOW}Installing necessary tools...${NC}"
apt -y install git wget curl || { echo -e "${RED}Failed to install necessary tools (git, wget, curl). Check package availability on your system.${NC}"; exit 1; }

# Package cleanup (optional)
echo -e "${YELLOW}Cleaning up unnecessary packages...${NC}"
apt autoremove -y || { echo -e "${RED}Failed to remove unnecessary packages.${NC}"; exit 1; }

# Zabbly PPA Setup (verify fingerprint before proceeding!)

# Download key
echo -e "${YELLOW}Downloading Zabbly PPA key...${NC}"
sudo curl -fsSL https://pkgs.zabbly.com/key.asc -o /tmp/zabbly.asc || { echo -e "${RED}Failed to download Zabbly PPA key. Check the URL or your internet connection.${NC}"; exit 1; }

# Verify fingerprint
echo -e "${YELLOW}Verifying key fingerprint...${NC}"
gpg --show-keys --fingerprint /tmp/zabbly.asc
echo -e "${RED}**Important:**${NC}"
echo "Compare the fingerprint above with the official Zabbly documentation or a trusted source. If they don't match, DO NOT proceed further."
read -p "Press Enter to continue verification (or Ctrl+C to abort): "

# Import key if verification passes
echo -e "${YELLOW}Importing key...${NC}"
sudo mv /tmp/zabbly.asc /etc/apt/trusted.gpg.d/zabbly.asc || { echo -e "${RED}Failed to move downloaded key to its designated location.${NC}"; exit 1; }

# Detect Debian suite name
echo -e "${YELLOW}Detecting Debian suite name...${NC}"
suite=$(lsb_release -c | awk '{print $2}') || { echo -e "${RED}Failed to detect suite name. Exiting.${NC}"; exit 1; }
echo -e "${GREEN}Detected suite: $suite${NC}"

# Create PPA source file
echo -e "${YELLOW}Creating PPA source file...${NC}"
cat <<EOF | sudo tee /etc/apt/sources.list.d/zabbly-kernel-stable.list
deb [signed-by=/etc/apt/trusted.gpg.d/zabbly.asc] https://pkgs.zabbly.com/kernel/stable $suite main
EOF

# Update package list with new PPA
echo -e "${YELLOW}Updating package list with new PPA...${NC}"
apt update || { echo -e "${RED}Failed to update package list after adding PPA. Please check the repository URL and configuration.${NC}"; exit 1; }

# Install mainline kernel package
echo -e "${YELLOW}Installing mainline kernel package...${NC}"
apt-get install -y linux-zabbly || { echo -e "${RED}Failed to install mainline kernel package. Check availability on the PPA or consider a different kernel version.${NC}"; exit 1; }

# Final system updates and cleanup
echo -e "${YELLOW}Performing final system upgrades...${NC}"
apt upgrade -y || { echo -e "${RED}Failed to perform final system upgrades.${NC}"; exit 1; }
echo -e "${YELLOW}Cleaning up unnecessary packages...${NC}"
apt autoremove -y || { echo -e "${RED}Failed to remove unnecessary packages after installation.${NC}"; exit 1; }

# Update bootloader configuration
echo -e "${YELLOW}Updating bootloader configuration...${NC}"
update-grub || { echo -e "${RED}Failed to update bootloader configuration. Reboot might be required manually.${NC}"; exit 1; }

# Reboot the system (to apply changes)
echo -e "${GREEN}The script has finished. Your system will now reboot to apply the new kernel.${NC}"
read -p "Press Enter to reboot (or Ctrl+C to postpone): "
reboot || { echo -e "${RED}Failed to reboot the system. You might need to reboot manually.${NC}"; exit 1; }
