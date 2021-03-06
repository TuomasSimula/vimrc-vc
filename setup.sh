#!/usr/bin/env bash

# Setting useful paths to variables
file_path="`realpath "$0"`"				# Path to this file
dir_path="`dirname "$file_path"`"		# Directory where this file is
path_to_vimrc="$dir_path/vimrc"			# Path to vimrc in this dir
tgt_path="`realpath -s $HOME/.vimrc`"	# Where .vimrc should be for vim to read it

# Check if .vimrc already exists at home dir as file or symlink
if [ -f $HOME/.vimrc ] || [ -L $HOME/.vimrc ]; then
	# Ask if user wants to replace .vimrc with the new one
	read -p ".vimrc already exists, replace file? (y/n) " -r prompt

	if [[ $prompt =~ ^(yes|y)$ ]]; then
		# Yes -> remove old ~/.vimrc and link new one there
		
		if [ ! -d $dir_path/old-vimrc ]; then
			mkdir $dir_path/old-vimrc
		fi

		# Save old .vimrc with timestamp as identifier
		time=$(date +"%Y-%m-%dT%H:%M:%S")
		mv $HOME/.vimrc $dir_path/old-vimrc/.vimrc-$time

		# Link new .vimrc to correct place
		ln -s "$path_to_vimrc" $HOME/.vimrc
		echo "vimrc linked to $tgt_path"
		echo "old .vimrc saved to $dir_path/old-vimrc/.old-vimrc-$time"
	else
		echo "setup failed"
	fi
else
	# ~/.vimrc doesn't exist -> link vimrc there
	ln -s "$path_to_vimrc" $HOME/.vimrc
	echo "vimrc linked to $tgt_path"
fi


# Add update-vimrc.sh to $HOME/.profile file to run automatically on login

run_cmd="$dir_path/update-vimrc.sh"
# Check that ~/.profile exists and doesn't already have the command included
if [ -f $HOME/.profile ] ; then
	
	if ! grep -Fxq $run_cmd $HOME/.profile; then	
		# Append $run_cmd to ~/.profile
		echo "$run_cmd" >> $HOME/.profile
		echo "update-vimrc.sh added to $HOME/.profile"
	fi
# If previous failed, check if ~/.profile doesn't yet exist
elif ! [ -f $HOME/.profile ]; then
	# Create ~/.profile and add $run_cmd
	touch $HOME/.profile
	echo "$run_cmd" >> $HOME/.profile
	echo "update-vimrc.sh added to $HOME/.profile"
fi
