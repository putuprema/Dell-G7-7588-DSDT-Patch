#!/bin/bash
#set -x

echo "Mounting EFI partition..."
EFIDIR=$(./mount_efi.sh)

echo "Installing config.plist to $EFIDIR/EFI/CLOVER..."
cp config.plist "$EFIDIR/EFI/CLOVER/config.plist"

echo "Done!"
echo ""
#EOF
