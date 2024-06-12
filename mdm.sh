#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
NC='\033[0m' # No Color

# Function to display error messages and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to create a new user
create_new_user() {
    echo -e "${GRN}Creating a new user"
    local dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
    echo -e "${BLU}Enter user's full name (Default: MAC)"
    read -r realName
    realName="${realName:-MAC}"
    echo -e "${BLU}Enter username (WITHOUT ACCENTS) (Default: MAC)"
    read -r username
    username="${username:-MAC}"
    echo -e "${BLU}Enter password (Default: 1234)"
    read -rs passw
    passw="${passw:-1234}"
    
    # Create user
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" || error_exit "Failed to create user $username"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
    mkdir "/Volumes/Data/Users/$username" || error_exit "Failed to create home directory for user $username"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
    echo "$passw" | dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" || error_exit "Failed to set password for user $username"
    dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"
    echo "0.0.0.0 deviceenrollment.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts || error_exit "Failed to block deviceenrollment.apple.com"
    echo "0.0.0.0 mdmenrollment.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts || error_exit "Failed to block mdmenrollment.apple.com"
    echo "0.0.0.0 iprofiles.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts || error_exit "Failed to block iprofiles.apple.com"
    echo -e "${GRN}User $username created successfully"
}

# Main menu
echo ""
echo -e "Auto Tools for MacOS"
echo ""
PS3='Please enter your choice: '
options=("Bypass on Recovery" "Disable Notification (SIP)" "Disable Notification (Recovery)" "Check MDM Enrollment" "Quit")
select opt in "${options[@]}"; do
    case $opt in
        "Bypass on Recovery")
            # Add your code for "Bypass on Recovery" here
            ;;
        "Disable Notification (SIP)")
            # Add your code for "Disable Notification (SIP)" here
            ;;
        "Disable Notification (Recovery)")
            # Add your code for "Disable Notification (Recovery)" here
            ;;
        "Check MDM Enrollment")
            # Add your code for "Check MDM Enrollment" here
            ;;
        "Quit")
            break
            ;;
        *)
            echo -e "${RED}Invalid option $REPLY${NC}"
            ;;
    esac
done
