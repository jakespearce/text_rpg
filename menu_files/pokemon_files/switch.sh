#!/bin/bash

# user selects a pokemon using 'switch'. the user should be able to navigate the menu normally and select another pokemon for the switch. 
# at this point we simply swap the ordering of the values in /text_dungeon/character_files/pokemon_in_inventory.csv
# we then re-generate the gui component of the pokemon menu now that our pokemon are in the desired order.

pokemon_in_inventory="${HOME}/text_dungeon/character_files/pokemon_in_inventory.csv"
pokemon_menu_directory="${HOME}/text_dungeon/menu_files/pokemon_files"
pokemon_menu_file="/dev/shm/pokemon_menu"
menu_height=$( wc -l < "$pokemon_menu_file" )
where_selection_is_pokemon_menu="${HOME}/text_dungeon/menu_files/pokemon_files/where_selection_is_pokemon_menu"


# we'll use this postion value for the pokemon we selected to switch
while read line; do
    pokemon_menu_position="$line"
done < "$where_selection_is_pokemon_menu"
# our starting position for this script will be the same starting position as where the pokemon to switch is
where_selection_is=$pokemon_menu_position


menu_tools="${HOME}/text_dungeon/menu_files/menu_tools.sh"
source "$menu_tools"
selection_adjuster=4


# todo: get the pokemonUniqueID for the pokemon that corresponds to where_selection_is
get_pokemon_to_swap(){


	local count=0
	target_line=$(( $where_selection_is + 2 ))

	while read moveOne moveTwo moveThree moveFour pokemonUniqueID; do
		((count++))
		if [ "$count" -eq "$target_line" ]; then
			pokemonUniqueID_to_swap="$pokemonUniqueID"
		fi
	done < "$pokemon_menu_file"
}


get_pokemon_to_swap


get_the_swapee(){


    count=0
    target_line=$(( $where_selection_is + 2 ))
    while read moveOne moveTwo moveThree moveFour pokemonUniqueID; do
        ((count++))
        if [ "$count" -eq "$target_line" ]; then
            pokemonUniqueID_swapee="$pokemonUniqueID"
        fi  
    done < "$pokemon_menu_file"
}


# this function swaps the two pokemonUniqueIDs in the $pokemon_in_inventory file.
# it then regenerates the pokemon menu now that the pokemon are in the desired order.
the_swap(){


	temp_pokemon_in_inventory="${pokemon_menu_directory}/temp_pokemon_in_inventory.csv"
	touch "$temp_pokemon_in_inventory"
	IFS_OLD=$IFS
	IFS="."
	while read inventory_pokemonUniqueID pokemonID; do
		if [ "$inventory_pokemonUniqueID" -eq "$pokemonUniqueID_to_swap" ]; then
			echo "${pokemonUniqueID_swapee}.${pokemonID}" >> "$temp_pokemon_in_inventory"
		elif [ "$inventory_pokemonUniqueID" -eq "$pokemonUniqueID_swapee" ]; then
			echo "${pokemonUniqueID_to_swap}.${pokemonID}" >> "$temp_pokemon_in_inventory"
		else
			echo "${inventory_pokemonUniqueID}.${pokemonID}" >> "$temp_pokemon_in_inventory"
		fi
	done < "$pokemon_in_inventory"
	IFS=$IFS_OLD

	mv "$temp_pokemon_in_inventory" "$pokemon_in_inventory"
	clear
	bash "${pokemon_menu_directory}/generate_menu_gui.sh"
}


display_pokemon_menu() {


    IFS_OLD=$IFS
    IFS=""
    count=0;
    while read -r line; do
        ((count++))
        if [ $(( $count % 4 )) -ne 0 ]; then

            upper_limit_selection=$(( $pokemon_menu_position + 1 ))
			upper_limit_new_position=$(( $where_selection_is + 1 ))
            if [ "$count" -ge "$pokemon_menu_position" -a "$count" -le "$upper_limit_selection" ]; then
                echo $hiOn $line $hiOff
			elif [ "$count" -ge "$where_selection_is" -a "$count" -le "$upper_limit_new_position" ]; then
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
    echo "|       Move pokemon where?        |"
    echo "o----------------------------------o"
}


while :
do

    clear
    keep_selection_in_range "$where_selection_is" "$selection_adjuster"
    display_pokemon_menu
    text_prompt
	get_the_swapee
    read -n1 input < /dev/tty
    case $input in
    w) where_selection_is=$(( $where_selection_is -4 )) ;;
    s) where_selection_is=$(( $where_selection_is +4 )) ;;
    d) the_swap ; exit ;;
    a) clear ; exit ;;
    esac
done

