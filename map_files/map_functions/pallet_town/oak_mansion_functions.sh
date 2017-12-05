#!/bin/bash

map_function_conditions(){
	canWeMove="yes"

	# Exit Oak's mansion and return to pallet town
	if [ "$y_element" -eq 9 -a "$x_element" -ge 13 -a "$x_element" -le 14 ]; then
		change_conf_value "${character_config}" "current_map_char_is_on" 1
		get_new_map_info_set_start_pos 27 16
		display_map
		canWeMove="yes" 
	fi

	# Stop walking through walls: From top row to bottom: N, E, S, W
    if [ \
        \( "$y_element" -eq 1 -a "$x_element" -ge 1 \) -o \
        \( "$y_element" -ge 1 -a "$x_element" -eq 26 \) -o \
        \( "$y_element" -ge 9 -a "$x_element" -ge 15 \) -o \
		\( "$y_element" -ge 9 -a "$x_element" -le 12 \) -o \
        \( "$y_element" -ge 1 -a "$x_element" -eq 1 \) \
        ]; then
        canWeMove="no"
    fi

	# The PC in the NW corner of the room
    if [ \
		\( "$y_element" -eq 2 -a "$x_element" -ge 2 -a "$x_element" -le 3 \) \
		]; then
		canWeMove="no"
	fi 

	# The Pokeballs
	if [ \
		\( "$y_element" -eq 2 -a "$x_element" -ge 20 -a "$x_element" -le 22 \) \
		]; then
		canWeMove="no"
	fi

	# The Eastmost bookshelf
	if [ \
		\( "$y_element" -eq 4 -a "$x_element" -le 9 \) -o \
		\( "$y_element" -eq 5 -a "$x_element" -eq 10 \) -o \
		\( "$y_element" -eq 6 -a "$x_element" -le 10 \) \
		]; then
		canWeMove="no"
	fi

	# The Westmost bookshelf
	if [ \
		\( "$y_element" -eq 4 -a "$x_element" -ge 18 \) -o \
		\( "$y_element" -eq 5 -a "$x_element" -eq 17 \) -o \
		\( "$y_element" -eq 6 -a "$x_element" -ge 17 \) \
		]; then
		canWeMove="no"
	fi

}


interaction(){


	# The Eastmost bookshelf
	if [ \
		\( "$y" -eq 7 -a "$x" -ge 1 -a "$x" -le 11 \) \
		]; then
		rolling_dialogue 13 13 "$current_map_text_prompts"
	fi

	# The Westmost bookshelf
	if [ \
		\( "$y" -eq 7 -a "$x" -ge 16 \) \
		]; then
		rolling_dialogue 13 13 "$current_map_text_prompts"
	fi

	# The Girl by the Eastmost bookshelf
	if [ \
		\( "$y" -eq 8 -a "$x" -le 4 \) \
		]; then
		rolling_dialogue 2 4 "$current_map_text_prompts"
	fi

	# The scientist just to the right of The Girl by the Easmost bookshelf
	if [ \
		\( "$y" -eq 8 -a "$x" -ge 6 -a "$x" -le 8 \) \
		]; then
		rolling_dialogue 7 7 "$current_map_text_prompts"
	fi

	if [ \
		\( "$y" -eq 8 -a "$x" -ge 14 -a "$x" -le 16 \) \
		]; then
		rolling_dialogue 7 7 "$current_map_text_prompts"
	fi

}
