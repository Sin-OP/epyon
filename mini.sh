#!/bin/bash
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
NC='\033[0m'

# Function to check if a directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "Directory $1 does not exist. Creating..."
        mkdir -p "$1"
        if [ $? -ne 0 ]; then
            echo "Failed to create directory $1. Exiting."
            exit 1
        fi
    fi
}

echo ""
echo -e "Auto Tools for MacOS Recovery Terminal"
echo ""

# Prompt user for action selection
PS3='Please enter your choice: '
options=("Bypass on Recovery" "Disable Notification (SIP)" "Disable Notification (Recovery)" "Check MDM Enrollment" "Thoát")
select opt in "${options[@]}"; do
    case $opt in
        "Bypass on Recovery")
            echo -e "${GRN}Bypass on Recovery"
            # Specify paths for user creation
            dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
            recovery_volume='/Volumes/Macintosh HD'
            # Prompt for user details
            read -p "Enter user's real name (Default: MAC): " realName
            realName="${realName:-MAC}"
            read -p "Enter username (Default: MAC): " username
            username="${username:-MAC}"
            read -p "Enter password (Default: 1234): " passw
            passw="${passw:-1234}"
            # Create user
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
            check_directory "/Volumes/Data/Users/$username"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
            dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
            dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership $username
            # Modify hosts file
            check_directory "$recovery_volume/etc"
            echo "0.0.0.0 deviceenrollment.apple.com" | sudo tee -a "$recovery_volume/etc/hosts" >/dev/null
            echo "0.0.0.0 mdmenrollment.apple.com" | sudo tee -a "$recovery_volume/etc/hosts" >/dev/null
            echo "0.0.0.0 iprofiles.apple.com" | sudo tee -a "$recovery_volume/etc/hosts" >/dev/null
            echo -e "${GREEN}Successfully blocked hosts${NC}"
            # Create marker file
            touch "/Volumes/Data/private/var/db/.AppleSetupDone"
            # Remove configuration profiles
            rm -rf "$recovery_volume/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
            rm -rf "$recovery_volume/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
            touch "$recovery_volume/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            touch "$recovery_volume/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
            echo "----------------------"
            break
            ;;
        "Disable Notification (SIP)")
            echo -e "${RED}Please insert your password to proceed${NC}"
            # Remove SIP-related files
            sudo rm -f "/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
            sudo rm -f "/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
            sudo touch "/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            sudo touch "/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
            break
            ;;
        "Disable Notification (Recovery)")
            echo -e "${RED}Please insert your password to proceed${NC}"
            # Remove recovery-related files
            sudo rm -rf "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
            sudo rm -rf "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
            sudo touch "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            sudo touch "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
            break
            ;;
        "Check MDM Enrollment")
            echo ""
            echo -e "${GRN}Check MDM Enrollment. Error is success${NC}"
            echo ""
            echo -e "${RED}Please insert your password to proceed${NC}"
            # Check MDM enrollment
            sudo profiles show -type enrollment
            break
            ;;
        "Thoát")
            break
            ;;
        *)
            echo "Invalid option $REPLY"
            ;;
    esac
done
