#!/bin/bash

map_function_conditions(){
	canWeMove="yes"

	# Exit my house and return to pallet town
	if [ "$y_element" -eq 9 -a "$x_element" -ge 8 -a "$x_element" -le 9 ]; then
		change_conf_value "${character_config}" "current_map_char_is_on" 1
		get_new_map_info_set_start_pos 9 10
		canWeMove="yes"

	# Go to the second floor of my house
	elif [ "$y_element" -eq 2 -a "$x_element" -eq 22 ]; then
		change_conf_value "${character_config}" "current_map_char_is_on" 4
		get_new_map_info_set_start_pos 21 2
		canWeMove="yes"
	fi

	# Stop walking through walls: From top row to bottom: N, E, S, W
	if [ \
		\( "$y_element" -eq 1 -a "$x_element" -ge 1 \) -o \
		\( "$y_element" -ge 1 -a "$x_element" -eq 23 \) -o \
		\( "$y_element" -ge 9 -a "$x_element" -ge 10 \) -o \
		\( "$y_element" -ge 9 -a "$x_element" -le 7 \) -o \
		\( "$y_element" -ge 1 -a "$x_element" -eq 1 \) \
		 ]; then
		canWeMove="no"

	# Bookshelf at top left of room
	elif [ \
		\( "$y_element" -eq 2 -a "$x_element" -ge 1 -a "$x_element" -le 3 \) \
		]; then
		canWeMove="no"

	# TV at northernmost wall
	elif [ \
		\( "$y_element" -eq 2 -a "$x_element" -ge 11 -a "$x_element" -le 12 \) \
		]; then
		canWeMove="no"

	# Table in the center of the room
	elif [ \
		\( "$y_element" -eq 4 -a "$x_element" -ge 10 -a "$x_element" -le 14 \) -o \
		\( "$y_element" -ge 5 -a "$y_element" -le 6 -a "$x_element" -ge 9 -a "$x_element" -le 15 \) \
		]; then
		canWeMove="no"

	# Your mum
	elif [ \
		\( "$y_element" -eq 5 -a "$x_element" -eq 17 \) \
		]; then
		canWeMove="no"

	fi
}

interaction(){

	# TV
	if [ \
		\( "$y" -eq 3 -a "$x" -ge 10 -a "$x" -le 13 \) \
		]; then
		rolling_dialogue 1 1 "$current_map_text_prompts"

	# Bookshelf
	elif [ \
		\( "$y" -eq 3 -a "$x" -ge 2 -a "$x" -le 3 \) \
		]; then
		rolling_dialogue 2 2 "$current_map_text_prompts"

	# Mum
	elif [ \
		\( "$y" -ge 4 -a "$y" -le 6 -a "$x" -ge 16 -a "$x" -le 18 \) \
		]; then
		# There are a number of things Mum can say. They're laid out in lines 3-6 of $current_map_text_prompts.
		# She randomly says one thing per interaction.
		randomNumber=$( shuf -i 3-6 -n 1 )
		rolling_dialogue "$randomNumber" "$randomNumber" "$current_map_text_prompts"

	fi
	
}
