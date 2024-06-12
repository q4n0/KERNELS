This script automates the installation of a mainline Linux kernel from the Zabbly PPA on Debian-based distributions (excluding Ubuntu and Debian themselves). It streamlines the process by:

    Updating system packages
    Installing necessary tools (git, wget, curl)
    Adding the Zabbly PPA repository (verify fingerprint before proceeding)
    Installing the linux-zabbly package (likely containing the mainline kernel)
    Updating the bootloader configuration
    Rebooting the system (to apply changes)

Important Notes:

    Proceed with Caution! Installing a mainline kernel can potentially introduce instability on your system. Thoroughly research and understand the risks involved before running the script.
    Targeted for Debian-Based Systems: While it might work on some derivatives with modifications, extensive testing is recommended on your specific distribution.
    Official Methods Recommended (Non-Debian): If you're not using a Debian-based system, the script prioritizes safety and strongly encourages using official kernel installation methods provided by your distribution manager.

Installation:
Clone the repository:
     git clone https://github.com/q4n0/KERNELS
     
Make the Script Executable: Grant execute permissions using the following command:
    sudo chmod +x zab.sh

Run the Script (with Caution): Execute the script from your terminal:
./install_mainline_kernel.sh

    Important: Proceed with caution when installing a mainline kernel, as it can potentially introduce instability on your system. Thoroughly research and understand the risks involved before running the script.

Verification (Zabbly PPA Fingerprint):

Before proceeding, it's crucial to verify the fingerprint of the Zabbly PPA key downloaded by the script:

    Run the following command to display the fingerprint:
    Bash

    gpg --show-keys --fingerprint /etc/apt/keyrings/zabbly.asc

    Compare the fingerprint with the official Zabbly documentation or a trusted source. If they don't match, do not proceed further.

Disclaimer:

While this script aims to simplify the mainline kernel installation process, using a third-party PPA like Zabbly can introduce potential risks. Ensure you trust the source and understand any compatibility issues before proceeding.
