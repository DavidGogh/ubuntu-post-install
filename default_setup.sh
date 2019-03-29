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

# Main
function main {
    update_system 1
    install_favs 1
    install_favs_dev 1
    install_gnome_apps 1 
    install_gnome_extensions 1
    gsettings_config 1
    write_bash_aliases 1
    write_profile 1
    write_bashrc 1
    write_editorconfig 1
    install_chrome
    install_vscode
    install_ros
    purge_unused 1
    remove_orphans 1
    
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

# Quit
function quit {
	echo_message header "Starting 'quit' function"
	echo_message title "Exiting $TITLE..."
	# Draw window
	if (whiptail --title "Quit" --yesno "Are you sure you want quit?" 8 56) then
		echo_message welcome 'Thanks for using!'
		exit 99
	else
		main
	fi
}

# Import main functions
import_functions
# Welcome message
echo_message welcome "$TITLE"
# Run system checks
system_checks
# main
while :
do
	main
done

#END OF SCRIPT
