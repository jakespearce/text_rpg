#!/bin/bash

map_rw_path="/dev/shm"

get_map_info(){

    map="${maps[$current_map_char_is_on]}"
    x="${starting_x_coords[$current_map_char_is_on]}"
    y="${starting_y_coords[$current_map_char_is_on]}"
    map_height=$( wc -l < $map )
    chars_on_map=$( wc -c < $map )
    # -1 so we ignore the newline character
    map_width=$(( $(( $chars_on_map / $map_height )) - 1 ))
    # depending on what map the character is on, we load a different set of map functions. see map_function_conditions function
    current_map_functions="${map_functions[$current_map_char_is_on]}"
	current_map_quests="${map_quests[$current_map_char_is_on]}"
	current_map_text_prompts="${text_prompts[$current_map_char_is_on]}"
    source "$current_map_functions"
}


display_map(){

    cat "${map_rw_path}/marked_map_output"
}


# For Pallet Town this will overwrite the map 'pallet_town' in map_files/maps/pallet_town/
mark_source_map(){

	mapToWriteOver=$1
	mapToWrite="${map_rw_path}/marked_map_output"
	cp "$mapToWrite" "$mapToWriteOver"
}


# takes in three arguments: $x $y $character $map $map_width
# the map element at x,y is written as $character
change_map_element(){

	local target_x=$1
	local target_y=$2
	local characterToWrite=$3
	local changeMap=$4
	local mapWidth=$5

	local y_count=1
	local x_count=1
	local IFS_OLD=$IFS
	local IFS=;

	while read -r row; do
	
		if [ "$y_count" -eq "$target_y" ]; then
			target_yLine=$( echo -n $row )
			x_charNewLine=0
			
			while read -rn1 xCharacter; do
				((x_charNewLine++))
				
				if [ "$x_count" -eq "$target_x" ]; then
					echo -n "$characterToWrite"
				else
					echo -n "$xCharacter"
				fi

				((x_count++))

				if [ "$x_charNewLine" -eq "$mapWidth" ]; then
					echo "" # we want a newline at the end of the line
				fi
			done <<< $target_yLine

		else
			echo $row
		fi

		((y_count++))

	done < $changeMap > "${map_rw_path}/marked_map_output"

	local IFS=$IFS_OLD
	echo ""
	clear

}


get_new_map_info_set_start_pos(){

	source "${text_dungeon}/character_files/character.cfg"
	get_map_info
	x=$1
	y=$2
	change_map_element $x $y $playerCharacter $map $map_width # writes the character to the coordinates they should be at. playerCharacter is sourced from character.cfg. It's literally a character, the default is "C".
}


inspect_element(){ # may be called from change_map_element or perhaps using Cut or something

	x_element=$1
	y_element=$2
	map_function_conditions # x_element and y_element are used internally
}

up(){

    y=$(( $y - 1 ))
	inspect_element $x $y
 
	if [ $canWeMove == "yes" ]; then
		change_map_element $x $y $playerCharacter $map $map_width ; display_map

	else
		y=$(( $y + 1 ))
	fi
}

down(){

    y=$(( $y + 1 ))
	inspect_element $x $y
  
	if [ $canWeMove == "yes" ]; then
		change_map_element $x $y $playerCharacter $map $map_width ; display_map

	else
		y=$(( $y - 1 ))
	fi
}

left(){

    x=$(( x - 1 ))
	inspect_element $x $y
   
	if [ $canWeMove == "yes" ]; then
		change_map_element $x $y $playerCharacter $map $map_width ; display_map

	else
		 x=$(( $x + 1 ))
	fi
}

right(){

    x=$(( $x + 1 ))
	inspect_element $x $y
 
	if [ $canWeMove == "yes" ]; then
		change_map_element $x $y $playerCharacter $map $map_width ; display_map

	else
		 x=$(( $x - 1 ))
	fi
}


return_map_element(){

	local target_x=$1
	local target_y=$2
	local inspectMap=$3
	local mapWidth=$4

	local y_count=1
	local x_count=1
	local IFS_OLD=$IFS
	local IFS=;

	while read -r row; do
	
		if [ "$y_count" -eq "$target_y" ]; then
			x_charNewLine=0
			target_yLine=$( echo -n $row )
		
			while read -rn1 xCharacter; do
				((x_charNewLine++))
				
				if [ "$x_count" -eq "$target_x" ]; then
					returnedMapElement="$xCharacter"
				fi

				((x_count++))
			done <<< $target_yLine

		fi

		((y_count++))

	done < "$inspectMap"

	local IFS=$IFS_OLD

}


# TODO
# Our character disappears from the map when we're moving other characters
# Write something that identifies the previous tile that the moving character was on.
# This will be $replacementCharacter
# Usage: move_map_element $xInitial $yInitial $xFinal $yFinal $characterToMove $replacementCharacter $map
# Example: move_map_element 24 10 20 10 L "." "$map"

move_map_element(){

	xInitial=$1
	yInitial=$2
	xFinal=$3
	yFinal=$4
	characterToMove=$5
	replacementCharacter=$6
	map=$7


	xDiff=$(( $xFinal - $xInitial )) 
	yDiff=$(( $yFinal - $yInitial )) 
	if [ $xDiff -ne 0 ]; then
		[[ $xDiff -lt 0 ]] && xMod=-1 || xMod=1 ; yMod=0 ; absDiff=$( echo "sqrt(${xDiff}^2)" | bc )
	elif [ $yDiff -ne 0  ]; then
		[[ $yDiff -lt 0 ]] && yMod=-1 || yMod=1 ; xMod=0 ; absDiff=$( echo "sqrt(${yDiff}^2)" | bc )
	fi

	loopsCompleted=0
	leadingXValue=$(( $xInitial + $xMod ))
	trailingXValue=$xInitial
	leadingYValue=$(( $yInitial + $yMod ))
	trailingYValue=$yInitial

	return_map_element $x $y "$map" "$map_width"
	elementPlayerStandingOn="$returnedMapElement"

	until [ $loopsCompleted -eq $absDiff ]; do

		read -t 0.1 -N 255 # TODO Test this and see if it works.

		# this function call changes the map for the 'leading' character
		change_map_element $leadingXValue $leadingYValue $characterToMove "$map" "$map_width"
		mark_source_map	"$map"

		# for the player character so it doesn't disappear
		change_map_element $x $y $playerCharacter "$map" "$map_width"
		mark_source_map "$map"

		change_map_element $trailingXValue $trailingYValue $replacementCharacter "$map" "$map_width"
		mark_source_map	"$map"
		display_map
		sleep 1


		[[ $xMod -ne 0 ]] && leadingXValue=$(( $leadingXValue + $xMod )) ; trailingXValue=$(( $leadingXValue - $xMod ))
		[[ $yMod -ne 0 ]] && leadingYValue=$(( $leadingYValue + $yMod )) ; trailingYValue=$(( $leadingYValue - $yMod ))

		# returns the character element occupying (x,y) on the map as $replacementCharacter
		return_map_element $leadingXValue $leadingYValue "$map" "$map_width"
		replacementCharacter="$returnedMapElement"

		((loopsCompleted++))
	done

	# 1) Mark the element the player is standing on with what it was before the player stood there
	# 2) Mark the source map with this element
	# 3) Finally, write a 'soft' change to the map (ie. not marking the source map) with the playerChar so when the character moves there's no ghosting
	change_map_element $x $y "$elementPlayerStandingOn" "$map" "$map_width"
	mark_source_map "$map"
	change_map_element $x $y "$playerCharacter" "$map" "$map_width"
	display_map
}

