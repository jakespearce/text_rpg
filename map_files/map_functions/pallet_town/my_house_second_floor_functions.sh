#!/bin/bash

map_function_conditions(){
	canWeMove="yes"

	# Go to First floor of My House
	if [ "$y_element" -eq 2 -a "$x_element" -eq 21 ]; then
		change_conf_value "${character_config}" "current_map_char_is_on" 2
		get_new_map_info_set_start_pos 22 2
		canWeMove="yes"
	fi

    # Stop walking through walls: From top row to bottom: N, E, S, W
    if [ \
        \( "$y_element" -eq 1 -a "$x_element" -ge 1 \) -o \
        \( "$y_element" -ge 1 -a "$x_element" -eq 22 \) -o \
        \( "$y_element" -ge 10 -a "$x_element" -ge 10 \) -o \
        \( "$y_element" -ge 10 -a "$x_element" -le 7 \) -o \
        \( "$y_element" -ge 1 -a "$x_element" -eq 1 \) \
         ]; then
        canWeMove="no"

	# PC in top left hand corner
	elif [ \
		\( "$y_element" -eq 2 -a "$x_element" -ge 2 -a "$x_element" -le 6 \) \
		]; then
		canWeMove="no"

	# TV in the middle of the room
	elif [ \
		\( "$y_element" -eq 5 -a "$x_element" -ge 11 -a "$x_element" -le 12 \) \
		]; then
		canWeMove="no"

	# Bed in the bottom left hand corner
	elif [ \
		\( "$y_element" -ge 7 -a "$x_element" -eq 2 \) \
		]; then
		canWeMove="no"
	fi
}


interaction() {

	if [ \
		\( "$y" -ge 4 -a "$y" -le 6 -a "$x_element" -ge 9 -a "$x_element" -le 13 \) \
		]; then
		rolling_dialogue 1 1 "$current_map_text_prompts"
	fi

}

