#!/bin/bash

where_selection_is=2
generate_pokemon_menu_script="menu_files/pokemon_files/generate_menu_gui.sh"
moves_file="pokemon_database/common/moves/moves.tab"
pokemon_submenu="menu_files/pokemon_files/pokemon_submenu.sh"
menu_tools="menu_files/menu_tools.sh"
source "$menu_tools"
selection_adjuster=4
where_selection_is_pokemon_menu="menu_files/pokemon_files/where_selection_is_pokemon_menu"
bash "$generate_pokemon_menu_script"
pokemon_menu_file="/tmp/pokemon_menu"
menu_height=$( wc -l < "$pokemon_menu_file" )


display_menu() {


	IFS_OLD=$IFS
	IFS=""
	count=0;
	while read -r line; do

		((count++))
		if [ $(( $count % 4 )) -ne 0 ]; then
			upper_limit_selection=$(( $where_selection_is + 1 ))
			if [ "$count" -ge "$where_selection_is" -a "$count" -le "$upper_limit_selection" ]; then
				echo $hiOn $line $hiOff
			else
				echo $line
			fi
		fi
	done < "$pokemon_menu_file"
	IFS=$IFS_OLD
}


text_prompt(){


	echo "o----------------------------------o"
	echo "|        Choose a pokemon          |"
	echo "o----------------------------------o"
}


generate_submenu(){


	submenu="/tmp/submenu_pokemon_menu"
	count=0
	moves_line=$(( $where_selection_is + 2 ))
	# we're checking each of the pokemon's moves for HM moves.
	# if one of the moves is a HM move, we add the HM move to the submenu.
	while read moveOne moveTwo moveThree moveFour pokemonUniqueID; do

		((count++))
		if [ "$count" -eq "$moves_line" ]; then

			IFS_OLD=$IFS
			# IFS = tab
			IFS="	"
			for move in $moveOne $moveTwo $moveThree $moveFour; do
				while read move_id move_name TM_HM PP; do
					if [ "$move" -eq "$move_id" -a "$TM_HM" == "HM"  ]; then
						echo -n "$move_name " | tr [a-z] [A-Z] > "$submenu"
						echo "$move_id" >> "$submenu"
					fi
				done < "$moves_file"
			done
			IFS=$IFS_OLD
		fi

	done < "$pokemon_menu_file"

	echo "STATS" >> "$submenu"
	echo "SWITCH" >> "$submenu"
	echo "CANCEL" >> "$submenu"
}


while :
do

	clear
	keep_selection_in_range "$where_selection_is" "$selection_adjuster"
	display_menu
	text_prompt
	read -n1 input < /dev/tty
	case $input in
	w) where_selection_is=$(( $where_selection_is -4 )) ;;
	s) where_selection_is=$(( $where_selection_is +4 )) ;;
	d) generate_submenu ; echo "$where_selection_is" > "$where_selection_is_pokemon_menu" ; bash "$pokemon_submenu" ;;
	a) clear ; exit ;;
	esac
done

