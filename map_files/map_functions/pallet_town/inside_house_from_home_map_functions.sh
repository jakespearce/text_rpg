#!bin/bash


map_function_conditions(){

	canWeMove="yes"

  	if [ "$y_element" -eq 3 -a "$x_element" -eq 2 ]; then
    	canWeMove="no"
  	fi

  	# map changes
	# couldn't this shit somehow be more elegant? have some decorum you swine
  	if [ "$current_map_char_is_on" -eq 2 -a "$y_element" -eq 5 ]; then
    	if [ "$x_element" -eq 6 -o "$x_element" -eq 7 ]; then
      		change_conf_value "${character_config}" "current_map_char_is_on" 1
      		get_new_map_info_set_start_pos 9 10
    	fi
  	fi
}
