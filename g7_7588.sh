#!/bin/bash
#set -x

clear
echo "macOS Post-Install Scripts for Dell G7-7588 Laptop"
echo "=================================================="
echo ""
echo "Big thanks to RehabMan for all scripts used here!"
sleep 3
echo ""
echo "Downloading all necessary tools and kexts"
echo "========================================="
./download.sh
echo ""
echo "Installing all kexts and tools to its proper locations"
echo "======================================================"
./install_downloads.sh
echo ""
echo "Compiling SSDT-7588.aml"
echo "======================="
make
echo ""
echo "Installing SSDT-7588.aml to your EFI partition"
echo "=============================================="
make install
echo ""
echo "Installing config.plist to your EFI partition"
echo "============================================="
./install_config.sh
echo "Remember to customize the SMBIOS so you have a unique serial for iMessage to work."
sleep 2
echo ""
echo "INSTALLATION FINISHED"
echo "====================="
echo "Installation has finished. Enjoy macOS on your laptop! :)"
echo ""

#EOF
