#!/bin/bash

# Setup Ubuntu with default settings

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
