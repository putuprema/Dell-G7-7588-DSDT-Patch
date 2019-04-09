#!/bin/bash
#set -x

EXCEPTIONS="SMCBatteryManager.kext|SMCLightSensor.kext|SMCSuperIO.kext|VoodooI2CAtmelMXT.kext|VoodooI2CELAN.kext|VoodooI2CFTE.kext|VoodooI2CSynaptics.kext|VoodooI2CUPDDEngine.kext"
ESSENTIAL="VirtualSMC.kext AtherosE2200Ethernet.kext"

source "$(dirname ${BASH_SOURCE[0]})"/_tools/_install_subs.sh
warn_about_superuser

# install tools
install_tools

# install required kexts
install_download_kexts
install_brcmpatchram_kexts
install_atheros_e2200
install_backlight_kexts

# using FakePCIID_Intel_HDMI_Audio for HDEF
install_fakepciid_intel_hdmi_audio

# install CPUFriendDataProvider.kext for 800 MHz idle cpu frequency
install_kext CPUFriendDataProvider.kext

# LiluFriend and kernel cache rebuild
finish_kexts

# update kexts on EFI/CLOVER/kexts/Other
update_efi_kexts

#EOF
