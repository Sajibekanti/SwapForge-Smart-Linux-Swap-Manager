#!/bin/bash
#=====================================================================
#  🧩 SwapForge — Smart Linux Swap Manager
#  Developed by Sajibe Kanti
#  Security Engineer | Automation Specialist | Hosting Infrastructure Architect
#  Founder — PrenHost Ltd
#=====================================================================

# --- Color setup ---
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

clear
echo -e "${CYAN}${BOLD}"
echo "====================================================================="
echo "                 🧩 SwapForge — Smart Linux Swap Manager"
echo "====================================================================="
echo -e "${RESET}"
echo -e "${YELLOW}Author:${RESET} Sajibe Kanti"
echo -e "${YELLOW}Role:${RESET} Security Engineer | Automation Specialist | Hosting Infrastructure Architect"
echo -e "${YELLOW}Organization:${RESET} PrenHost Ltd"
echo ""

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}⚠️  Please run this script as root.${RESET}"
  exit 1
fi

# --- Detect if system uses LVM ---
if lsblk -f | grep -q "LVM2_member"; then
    IS_LVM=true
else
    IS_LVM=false
fi

echo -e "${YELLOW}System detected: ${RESET}$([[ $IS_LVM == true ]] && echo "LVM-based" || echo "Standard File-based")"
echo ""

# --- Main menu ---
echo "Select Action:"
echo "  1) Add Swap"
echo "  2) Delete Swap"
read -p "Enter choice [1-2]: " ACTION

# --- Error handler ---
error_exit() {
    echo -e "${RED}❌ Error: $1${RESET}"
    exit 1
}

#==============================================================
#   ADD SWAP FUNCTION
#==============================================================
add_swap() {
    read -p "Enter swap size (e.g., 10G or 2048M): " SWAP_SIZE
    read -p "Enter location (default: /home): " SWAP_LOC
    SWAP_LOC=${SWAP_LOC:-/home}

    echo -e "\nChoose swap creation method:"
    echo "  1) LVM-based (if available)"
    echo "  2) File-based"
    read -p "Enter choice [1-2]: " METHOD

    echo -e "\n${CYAN}>>> Starting swap creation process...${RESET}"

    if [[ "$METHOD" == "1" && "$IS_LVM" == true ]]; then
        VG=$(vgs --noheadings -o vg_name | awk '{print $1}' | head -n1)
        [[ -z "$VG" ]] && error_exit "No LVM volume group found."

        echo -e "${YELLOW}Creating LVM-based swap: $SWAP_SIZE on VG $VG...${RESET}"
        lvcreate -L "$SWAP_SIZE" -n swap_extra "$VG" || error_exit "Failed to create LV."
        mkswap "/dev/${VG}/swap_extra" || error_exit "mkswap failed."
        swapon "/dev/${VG}/swap_extra" || error_exit "swapon failed."

        if ! grep -q "/dev/${VG}/swap_extra" /etc/fstab; then
            echo "/dev/${VG}/swap_extra none swap sw 0 0" >> /etc/fstab
        fi
        echo -e "${GREEN}✅ LVM Swap created successfully!${RESET}"

    else
        SWAP_FILE="${SWAP_LOC}/swapfile"
        echo -e "${YELLOW}Creating file-based swap: ${SWAP_FILE} (${SWAP_SIZE})${RESET}"

        mkdir -p "$SWAP_LOC" || error_exit "Cannot access directory: $SWAP_LOC"

        fallocate -l "$SWAP_SIZE" "$SWAP_FILE" 2>/dev/null || \
        dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$((SWAP_SIZE)) || \
        error_exit "File allocation failed."

        chmod 600 "$SWAP_FILE"
        mkswap "$SWAP_FILE" || error_exit "mkswap failed."
        swapon "$SWAP_FILE" || error_exit "swapon failed."

        if ! grep -q "$SWAP_FILE" /etc/fstab; then
            echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
        fi

        echo -e "${GREEN}✅ File-based Swap created successfully!${RESET}"
    fi

    echo -e "\n${CYAN}>>> Swap Summary:${RESET}"
    swapon --show
    free -h
    echo -e "\n${YELLOW}Persistent entry added to /etc/fstab${RESET}"
}

#==============================================================
#   DELETE SWAP FUNCTION
#==============================================================
delete_swap() {
    echo -e "\n${CYAN}>>> Existing Swaps:${RESET}"
    swapon --show

    echo ""
    read -p "Enter the swap device or file path to remove (e.g., /dev/almalinux/swap_extra or /home/swapfile): " SWAP_TARGET

    [[ -z "$SWAP_TARGET" ]] && error_exit "No target provided."

    echo -e "${YELLOW}Disabling swap: ${SWAP_TARGET}${RESET}"
    swapoff "$SWAP_TARGET" 2>/dev/null || echo -e "${RED}⚠️  Failed to disable swap (may already be off).${RESET}"

    echo -e "${YELLOW}Removing entry from /etc/fstab...${RESET}"
    sed -i "\|$SWAP_TARGET|d" /etc/fstab

    if [[ -e "$SWAP_TARGET" ]]; then
        if [[ "$SWAP_TARGET" == /dev/* ]]; then
            echo -e "${YELLOW}Removing LVM logical volume...${RESET}"
            lvremove -f "$SWAP_TARGET" 2>/dev/null || echo -e "${RED}⚠️  Could not remove LV (may not exist).${RESET}"
        else
            echo -e "${YELLOW}Deleting swap file...${RESET}"
            rm -f "$SWAP_TARGET" || echo -e "${RED}⚠️  Could not delete file.${RESET}"
        fi
    fi

    echo -e "${GREEN}✅ Swap deleted successfully and entry removed from /etc/fstab.${RESET}"
}

#==============================================================
#   MAIN EXECUTION
#==============================================================
case "$ACTION" in
    1) add_swap ;;
    2) delete_swap ;;
    *) echo -e "${RED}Invalid choice. Exiting.${RESET}" ;;
esac

echo -e "\n${CYAN}${BOLD}Developed by Sajibe Kanti — PrenHost Ltd${RESET}"
echo -e "${YELLOW}Security Engineer | Automation Specialist | Hosting Infrastructure Architect${RESET}"
echo "====================================================================="
