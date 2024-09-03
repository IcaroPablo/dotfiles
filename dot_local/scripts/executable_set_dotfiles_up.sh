#!/bin/bash

# create backups of the existing dotfiles in system (defined at dotfiles_list below)
# takes $HOME as first positional argument
# TODO problems with root directories, must request sudo

HOME=$1
dotfiles_folder="$(pwd)/dotfiles"
dotfiles_backup_folder="$(pwd)/dotfiles_backup"

echo "HOME defined as $HOME"
echo "dotfiles_folder defined as $dotfiles_folder"
echo "dotfiles_backup_folder defined as $dotfiles_backup_folder"
echo ""

dotfiles_list=(
"$HOME/.xinitrc"
"$HOME/.bashrc"
"$HOME/.zshrc"
"$HOME/.vimrc"
"$HOME/.xprofile"
"$HOME/.config/nvim/init.vim"
"$HOME/.config/mimeapps.list"
"$HOME/.config/picom/picom.conf"
"$HOME/.config/snownews/urls.opml"
"/etc/pacman.conf"
"/etc/pacman.d/mirrorlist"
)

for dotfile in ${dotfiles_list[@]}; do

	#getting dotfile name
	dotfile_name="$(echo $dotfile | sed 's/\// /g' | awk '{print $NF}')"

	#getting dotfile location
	dotfile_location="$(echo $dotfile | sed 's%/[^/]*$%/%')"
	
	# change dotfile name and move it to dotfiles_backup folder
	echo "backing up $dotfile"
	bkpname="$(echo $dotfile_name)-bkp-$(printf '%(%Y-%m-%d_%H-%M-%S)T')"
	echo "storing $bkpname in $dotfiles_backup_folder"

	# despite this script can deal with links it only works with source files named alike its links
	if [ -L "$dotfile" ]; then
		echo "$dotfile is a link"
    	dotfile_link_source="$(readlink $dotfile)"
		echo "link source: $dotfile_link_source"
		
		if [ "$(echo $dotfile_link_source)" != "$(echo $dotfiles_folder/$dotfile_name)" ]; then
			echo "backing up original file"
			mv $dotfile_link_source $dotfiles_backup_folder
			mv "$dotfiles_backup_folder/$dotfile_name" "$dotfiles_backup_folder/$bkpname"
		fi

        echo "deleting link"
	    rm -rf $dotfile

	else
		mv $dotfile $dotfiles_backup_folder
		mv "$dotfiles_backup_folder/$dotfile_name" "$dotfiles_backup_folder/$bkpname"
	fi

    # link saved version of the dotfile to the correct location
    echo "creating link for $dotfiles_folder/$dotfile_name at $dotfile_location"
	ln -s $dotfiles_folder/$dotfile_name $dotfile_location
    echo ""

done
