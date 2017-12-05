#!/bin/bash

# Everything aside from moving around the map is a script that runs over the top of this one.

text_dungeon="${HOME}/text_dungeon"
character_config="${text_dungeon}/character_files/character.cfg"

source "${text_dungeon}/character_files/character.cfg"
source "${text_dungeon}/map_files/maps.cfg"
source "${text_dungeon}/map_files/map_tools.sh"
source "${text_dungeon}/generic_tools/tools.sh"


input_prompt(){

	read -n1 input
	case $input in
		w) up ;;
		s) down ;;
		a) left ;;
		d) right ;;
		# interaction is a function found whatever the current_map_functions file is set to
		e) clear ; cat "${map_rw_path}/marked_map_output" ; echo "" ; echo -n " " ; interaction ;;
		m) bash ${text_dungeon}/menu_files/menu.sh ; cat "${map_rw_path}/marked_map_output" ;;
		*) echo "WASD to move, e to interact with things, m for menu." ;;
	esac
}


get_map_info

while true; do
	stty_OLD=$( stty -g )
	stty -echo 		# so the user can't see their own input
	input_prompt
	stty $stty_OLD
done
