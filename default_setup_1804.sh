#!/bin/bash

# Setup Ubuntu with default settings
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Authors:
#   Yuxiang Gap <ygao73@jhu.edu>
#
# Description:
#   A post-installation bash script for Ubuntu
#
# Legal Preamble:
#
# This script is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; version 3.
#
# This script is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <https://www.gnu.org/licenses/gpl-3.0.txt>

# tab width
tabs 4
clear

# Title of script set
TITLE="Ubuntu Post-Install Script"
WITHOUT_GUI=1 # 1 without gui, 0 with gui
# Main
function main {
    update_system
    superuser_do "snap install node --channel=10/stable --classic"
    superuser_do "snap install vscode --classic"
    superuser_do "snap install docker"
    superuser_do "snap install google-cloud-sdk --classic"
    superuser_do "snap install snap-store"
    superuser_do "snap install slack --classic"
    install_chrome
    install_docker_compose
    install_from_list "preferred applications" "favs"
    install_from_list "preferred development tools" "favs-dev"
    install_from_list "preferred utilities" "favs-utils"
    install_gnome_apps
    install_shell_extensions

    gsettings_config
    disable_crash_dialogs
    write_bash_aliases
    write_profile
    write_bashrc
    write_editorconfig
    install_vimrc

    clean_apt_cache
    remove_orphans
    remove_leftovers
    purge_unused
	purge_snaps
    #sudo reboot
}

# Import Functions
function import_functions {
	DIR="functions"
	# iterate through the files in the 'functions' folder
	for FUNCTION in $(dirname "$0")/$DIR/*; do
		# skip directories
		if [[ -d $FUNCTION ]]; then
			continue
		# exclude markdown readmes
		elif [[ $FUNCTION == *.md ]]; then
			continue
		elif [[ -f $FUNCTION ]]; then
			# source the function file
			. $FUNCTION
		fi
	done
}

# Automatically import apps functions
function import_apps_functions {
	DIR="functions/apps"
	# iterate through the files in the 'functions/apps' folder
	for FUNCTION in $(dirname "$0")/$DIR/*; do
		if [[ -d $FUNCTION ]]; then
			continue
		elif [[ $FUNCTION == *.sh ]]; then
			continue
		elif [[ -f $FUNCTION ]]; then
			# source the function file
			. $FUNCTION
		fi
	done
}

# Quit
function quit {
	echo_message header "Starting 'quit' function"
	echo_message title "Exiting $TITLE..."
	# Draw window
	if (whiptail --title "Quit" --yesno "Are you sure you want quit?" 8 56) then
		echo_message welcome 'Thanks for using!'
		exit 99
	# else
	# 	main
	fi
}

# Import main functions
import_functions
import_apps_functions
# Welcome message
echo_message welcome "$TITLE"
# Run system checks
system_checks
# main
main

unset WITHOUT_GUI

#END OF SCRIPT
