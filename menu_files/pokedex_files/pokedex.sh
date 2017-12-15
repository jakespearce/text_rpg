#!/bin/bash

source "generic_tools/tools.sh"
pokedex_files="menu_files/pokedex_files"
where_selection_is=1
menu_tools="menu_files/menu_tools.sh"
source "$menu_tools"
selection_adjuster=1


# for a more indepth explanation on what these variables do, read the comments above the reposition_window() function.
# tl;dr the value of lines_after_selection determines how many menu items a player sees at any given time. we only show a small window of menu items at any given time because showing all 151 pokedex menu lines at once would be luudicrous.
lines_before_selection=1
lines_after_selection=7

# could hard code 151, for 151 original pokemon, BUT WE GOTTA THINK OF THE SEQUEL BABY
menu_height=$( wc -l < "${pokedex_files}/pokedex"  )

# for displaying the pokedex when we first run pokedex.sh
# this is pretty much the refresh_menu function from menu.sh
refresh_pokedex(){

	count=;
	while read id name seen own; do

		((count++))

	# the statements below 'modify' how the pokemon will be displayed to the player. Remember the only thing the player actually sees is the /dev/shm/marked_pokedex file.

		# for when that item is 'selected'
		if [ "$count" -eq "$where_selection_is" ]; then
			# if we've not seen the pokemon before and not caught it
			if [ "$seen" -eq 0 -a "$own" -eq 0 ]; then
				echo $id "---------" "selected"
			
			# if we've seen the pokemon before and not caught it
			elif [ "$seen" -eq 1 -a "$own" -eq 0 ]; then
				echo $id $name "selected"

			# if we've seen the pokemon before and caught it
			else
				echo $id "${name}*" "selected"
			fi

		# for when an item is not 'selected'
		else
            # if we've not seen the pokemon before and not caught it
            if [ "$seen" -eq 0 -a "$own" -eq 0 ]; then
                echo $id "---------"
                
            # if we've seen the pokemon before and not caught it
            elif [ "$seen" -eq 1 -a "$own" -eq 0 ]; then
                echo $id $name

            # if we've seen the pokemon before and caught it
            else
                echo $id "${name}*"
			fi
		fi
	
	done < "${pokedex_files}/pokedex" > /dev/shm/marked_pokedex
				
}


show_pokedex(){

	reposition_window

	local count=0

		while read id name selected; do
		
			((count++))
		
			if [ "$count" -ge "$lines_before_selection" -a $count -le "$lines_after_selection"  ]; then
	
				if [ "$selected" == "selected"  ]; then
					echo "$hiOn $id $name $hiOff"
				else
					echo "$id $name"
				fi

			fi

		done < /dev/shm/marked_pokedex

}


# lines_before_selection = before where_selection_is
# lines_after_selection = in front of where_selection_is
# This function is used in show_pokedex so that the player only sees 7 menu items at a time. How 7? Because we initally set lines_after_selection=7 and lines_before_selection=0
# lines_before_selection to lines_after_selection represents a range of menu lines that the player sees. This range is primarily controlled by $where_selection_is. 
# reposition_window shifts our visible range of menu items up or down depending in which direction $where_selection_is drags it.
reposition_window(){

	if [ "$where_selection_is" -lt "$lines_before_selection" -a "$lines_before_selection" -ne 1 ]; then
		lines_before_selection=$(( $lines_before_selection - 1 ))
		lines_after_selection=$(( $lines_after_selection - 1 ))
	
	elif [ "$where_selection_is" -gt "$lines_after_selection" -a "$lines_after_selection" -ne "$menu_height" ]; then
		lines_before_selection=$(( $lines_before_selection + 1  ))
		lines_after_selection=$(( $lines_after_selection + 1 ))
	fi
}


select_pokemon(){

	selected_pokemon=$1	
	local count=0

	while read id name seen own; do

	((count++))
	if [ "$count" -eq "$selected_pokemon" ]; then
		bash "${pokedex_files}/select_pokedex_pokemon.sh" $id $seen $own
	fi	

	done < "${pokedex_files}/pokedex"
}


input_prompt(){

	while :
	do 

		clear
		keep_selection_in_range "$where_selection_is" "$selection_adjuster"
		refresh_pokedex
		show_pokedex

		# why from /dev/tty? 
		# once you get a few shells deep (like we are here) stdin fucks up
		# input < /dev/tty means we'll get input from a new tty session (i think?)
		# if a while loop is a subshell, then we're like 5 deep here or something.
		# gui_and_input while (1) + menu.sh call (2) + menu.sh while (3) + pokedex.sh (4) + pokdex.sh while (5)
		# find out more about this. idgi.
		read -n1 input < /dev/tty
		case $input in
   		    w|W) where_selection_is=$(( $where_selection_is - 1 )) ;;
        	s|S) where_selection_is=$(( $where_selection_is + 1 )) ;;
        	# empty string is enter key
        	""|d) select_pokemon $where_selection_is ;;
        	a|b) clear ; exit ;;
    	esac

	done
}

input_prompt

