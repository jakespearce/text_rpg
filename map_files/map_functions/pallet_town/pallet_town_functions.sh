#!bin/bash

map_function_conditions(){

	canWeMove="yes" # this will be one of a few similar variables, eg. canWeCut would be present here, defaulting as "no", if there were a tree to cut down on the map.

  	# map swaps - always have to come before stops
  	# enter leftmost house
	if [ "$y_element" -eq 9 ]; then

		# Enter My House (house top left of the map)
		if [ "$x_element" -eq 9 -o "$x_element" -eq 10 ]; then
			change_conf_value "${character_config}" "current_map_char_is_on" 2
			get_new_map_info_set_start_pos 8 8
		fi

		# Enter Gary's house (top right of the map)
		if [ "$x_element" -eq 28 -o "$x_element" -eq 29 ]; then
			change_conf_value "${character_config}" "current_map_char_is_on" 5
			get_new_map_info_set_start_pos 9 8
		fi

    # Exit north of map - needs some attention!
	elif [ "$y_element" -eq 1 -a "$x_element" -ge 21 -a "$x_element" -le 24 ]; then
			change_conf_value "${character_config}" "current_map_char_is_on" 3
			get_new_map_info_set_start_pos 16 12
	fi



  	# stop being able to walk through the leftmost house
	if [ \
		\( "$y_element" -eq 6 -a "$x_element" -ge 10 -a "$x_element" -le 15 \) -o \
		\( "$y_element" -eq 7 -a "$x_element" -ge 9 -a "$x_element" -le 16 \) -o \
		\( "$y_element" -ge 8 -a "$y_element" -le 9 -a "$x_element" -eq 8 \) -o \
		\( "$y_element" -ge 8 -a "$y_element" -le 9 -a "$x_element" -ge 11 -a "$x_element" -le 17 \) \
		]; then
		canWeMove="no"
	fi

	# stop being able to walk through the rightmost house
	# V1
	if [ \
		\( "$y_element" -eq 6 -a "$x_element" -ge 29 -a "$x_element" -le 34 \) -o \
		\( "$y_element" -eq 7 -a "$x_element" -ge 28 -a "$x_element" -le 35 \) -o \
		\( "$y_element" -ge 8 -a "$y_element" -le 9 -a "$x_element" -eq 27 \) -o \
		\( "$y_element" -ge 8 -a "$y_element" -le 9 -a "$x_element" -ge 30 -a "$x_element" -le 36 \) \
		]; then
		canWeMove="no"
	fi


	# Stop being able to walk through Oak's mansion
	if [ \
		\( "$y_element" -eq 12 -a "$x_element" -ge 20 -a "$x_element" -le 35 \) -o \
		\( "$y_element" -ge 13 -a "$y_element" -le 14 -a "$x_element" -ge 19 -a "$x_element" -le 36 \) -o \
		\( "$y_element" -eq 15 -a "$x_element" -ge 19 -a "$x_element" -le 36 \) \
		]; then
		canWeMove="no"
		if [ "$y_element" -eq 15 -a "$x_element" -ge 27 -a "$x_element" -le 28 ]; then
				change_conf_value "${character_config}" "current_map_char_is_on" 3
				get_new_map_info_set_start_pos 13 8
				display_map
				canWeMove="yes"
		fi
	fi

	# Map edges starting from North and going clockwise.
	if [ \
		\( "$y_element" -ge 1 -a "$y_element" -le 18 -a "$x_element" -eq 1 \) -o \
		\( "$y_element" -eq 2 -a "$x_element" -ge 1 -a "$x_element" -le 20 \) -o \
		\( "$y_element" -eq 2 -a "$x_element" -ge 25 \) -o \
		\( "$y_element" -ge 1 -a "$x_element" -eq 42 \) -o \
		\( "$y_element" -eq 17 -a "$x_element" -eq 2 \) -o \
		\( "$y_element" -eq 18 -a "$x_element" -ge 1 -a "$x_element" -le 8 \) -o \
		\( "$y_element" -ge 15 -a "$x_element" -ge 9 -a "$x_element" -le 14 \) -o \
		\( "$y_element" -eq 18 -a "$x_element" -ge 15 \) \
		]; then
		canWeMove="no"
	fi
	
}


interaction(){

	# My house sign
	if [ "$y" -eq 10 -a "$x" -ge 4 -a "$x" -le 6 ]; then
		# source: tools.sh
		rolling_dialogue 2 2 "$current_map_text_prompts"
	fi

	# Gary's house sign
	if [ "$y" -eq 10 -a "$x" -ge 23 -a "$x" -le 25 ]; then
		rolling_dialogue 5 5 "$current_map_text_prompts"
	fi

	# Little girl ("G")
	if [ "$y" -ge 11 -a "$y" -le 13 -a "$x" -ge 4 -a "$x" -le 6 ]; then
		rolling_dialogue 21 22 "$current_map_text_prompts"
	fi 

	# Main town sign near to Little girl
	if [ "$y" -ge 12 -a "$y" -le 13 -a "$x" -ge 11 -a "$x" -le 15 ]; then
		rolling_dialogue 25 26 "$current_map_text_prompts"
	fi

	# Large Man ("M")
	if [ "$y" -ge 16 -a "$y" -le 18 -a "$x" -ge 18 -a "$x" -le 20 ]; then
		rolling_dialogue 16 18 "$current_map_text_prompts"
	fi
}


