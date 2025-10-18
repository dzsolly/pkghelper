# Interactive DNF Assistant for RHEL-like Systems

pkghelper.sh is a fast, modular, and terminal-friendly Bash script designed to simplify package management on RHEL 8 and compatible distributions like AlmaLinux and Rocky Linux. It provides an interactive menu for common DNF operations, with audit logging, repo toggling, and intelligent formatting.

## ⚙️ Features

✅ Interactive menu for updating, installing, removing, and inspecting packages
✅ Fast repository listing with color-coded status and short descriptions
✅ Toggle repositories by number, no need to type repo IDs
✅ Audit logging of all actions to $HOME/.pkghelper/logs/actions.log
✅ Cross-distro compatible (AlmaLinux, Rocky Linux, RHEL)
✅ No external dependencies – pure Bash + DNF

## 📋 Menu Options

1) Update system
2) Search for package
3) Install package
4) Remove package
5) Get package info
6) List repositories (fast, with toggle)
0) Exit

## 🧠 Smart Repo Listing

The List repositories function:
Lists all enabled repos first (✔ green)
Lists all disabled repos below (❌ red)
Includes short descriptions from dnf repolist all

## 🛡️ Audit Logging

All actions are logged to:
~/.pkghelper/logs/actions.log

Each entry includes timestamp and action summary.

## 📦 Installation

Clone the repo and make the script executable:

git clone https://github.com/dzsolly/pkghelper
cd pkghelper
chmod +x pkghelper.sh
./pkghelper.sh

## 🧰 Requirements

Bash 4+
DNF package manager
sudo access for install/remove/toggle operations

## 📌 Notes

Repo descriptions are extracted from dnf repolist all, not dnf repoinfo, for speed.
Debug/source/testing repos are listed but not recommended for general use.
Repo toggling is safe and reversible.

##  📄 License

MIT License — free to use, modify, and distribute.
Assigns numbers to each repo for easy toggling

Uses fast parsing (no repoinfo calls) for performance
