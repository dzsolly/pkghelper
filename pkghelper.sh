#!/bin/bash

# pkghelper.sh – Simple interactive DNF package manager for RHEL 8 and compatible systems

LOGDIR="$HOME/.pkghelper/logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/actions.log"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function log_action() {
    echo "$(date '+%F %T') | $1" >> "$LOGFILE"
}

function pause() {
    read -rp "Press Enter to continue..."
}

function update_system() {
    echo "🔄 Updating system..."
    sudo dnf upgrade -y && log_action "System upgraded"
    pause
}

function search_package() {
    read -rp "🔍 Enter package name to search: " pkg
    dnf search "$pkg" | tee >(log_action "Searched for: $pkg")
    pause
}

function install_package() {
    read -rp "📦 Enter package name to install: " pkg
    sudo dnf install -y "$pkg" && log_action "Installed: $pkg"
    pause
}

function remove_package() {
    read -rp "🗑️ Enter package name to remove: " pkg
    sudo dnf remove -y "$pkg" && log_action "Removed: $pkg"
    pause
}

function package_info() {
    read -rp "ℹ️ Enter package name for info: " pkg

    if rpm -q "$pkg" &>/dev/null; then
        echo "📦 Package is installed. Showing installed info:"
        rpm -qi "$pkg" | tee >(log_action "Queried installed info for: $pkg")
    else
        match=$(rpm -qa | grep -i "^$pkg" | head -n 1)
        if [[ -n "$match" ]]; then
            echo "📦 Found installed package: $match"
            rpm -qi "$match" | tee >(log_action "Queried installed info for: $match")
        else
            echo "📦 Package is not installed. Showing DNF info:"
            dnf info "$pkg" | tee >(log_action "Queried available info for: $pkg")
        fi
    fi
    pause
}

function list_repos() {
    echo "📋 Repositories:"
    mapfile -t all_repos < <(dnf repolist all | awk 'NR>1 {id=$1; status=$NF; sub(id FS, "", $0); sub(FS status "$", "", $0); print id, status, $0}')
    declare -A repo_map
    index=1

    # First: enabled repos
    for entry in "${all_repos[@]}"; do
        name=$(echo "$entry" | awk '{print $1}')
        status=$(echo "$entry" | awk '{print $2}')
        desc=$(echo "$entry" | cut -d' ' -f3-)
        [[ -z "$desc" ]] && desc="(no description)"
        if [[ "$status" == "enabled" ]]; then
            repo_map[$index]="$name"
            echo -e "$index) ${GREEN}✔ $name${NC} – $desc"
            ((index++))
        fi
    done

    # Then: disabled repos
    for entry in "${all_repos[@]}"; do
        name=$(echo "$entry" | awk '{print $1}')
        status=$(echo "$entry" | awk '{print $2}')
        desc=$(echo "$entry" | cut -d' ' -f3-)
        [[ -z "$desc" ]] && desc="(no description)"
        if [[ "$status" == "disabled" ]]; then
            repo_map[$index]="$name"
            echo -e "$index) ${RED}❌ $name${NC} – $desc"
            ((index++))
        fi
    done

    log_action "Listed repositories (fast mode)"

    read -rp $'\nDo you want to toggle a repository by number? (y/n): ' toggle
    if [[ "$toggle" == "y" ]]; then
        read -rp "Enter repository number to toggle: " num
        selected="${repo_map[$num]}"

        if [[ -z "$selected" ]]; then
            echo "⚠️ Invalid selection."
        else
            current_status=$(dnf repolist all | awk -v id="$selected" '$1 == id {print $NF}')
            if [[ "$current_status" == "enabled" ]]; then
                sudo dnf config-manager --set-disabled "$selected" && log_action "Disabled repo: $selected"
                echo "❌ Repo '$selected' has been disabled."
            elif [[ "$current_status" == "disabled" ]]; then
                sudo dnf config-manager --set-enabled "$selected" && log_action "Enabled repo: $selected"
                echo "✅ Repo '$selected' has been enabled."
            else
                echo "⚠️ Could not determine status of '$selected'."
            fi
        fi
    fi
    pause
}

function main_menu() {
    while true; do
        clear
        echo "=== 📦 pkghelper – RHEL 8 and Compatible Systems Package Management Assistant ==="
        echo "1) Update system"
        echo "2) Search for package"
        echo "3) Install package"
        echo "4) Remove package"
        echo "5) Get package info"
        echo "6) List repositories (fast, with toggle)"
        echo "0) Exit"
        read -rp "Choose an option: " choice

        case "$choice" in
            1) update_system ;;
            2) search_package ;;
            3) install_package ;;
            4) remove_package ;;
            5) package_info ;;
            6) list_repos ;;
            0) echo "Exiting..."; break ;;
            *) echo "❌ Invalid choice"; pause ;;
        esac
    done
}

main_menu
