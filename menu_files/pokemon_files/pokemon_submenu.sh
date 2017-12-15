#!/bin/bash

pokemon_menu_file="/dev/shm/pokemon_menu"
pokemon_submenu_file="/dev/shm/submenu_pokemon_menu"
hiOn=$( tput smso )
hiOff=$( tput rmso )
menu_height=$( wc -l < "$pokemon_submenu_file" )
where_selection_is=1
switch="menu_files/pokemon_files/switch.sh"
stats="menu_files/pokemon_files/stats.sh"
menu_tools="menu_files/menu_tools.sh"
source "$menu_tools"
# used for keeping the menu selection in range
selection_adjuster=1
where_selection_is_pokemon_menu="menu_files/pokemon_files/where_selection_is_pokemon_menu"


while read line; do
	pokemon_menu_position="$line"
done < "$where_selection_is_pokemon_menu"


#make some decisions about what each item does. 
display_submenu(){


	count=0
	while read line_item HM_id; do
		((count++))
		if [ "$where_selection_is" -eq "$count"  ]; then
			echo $hiOn "$line_item" $hiOff
		else
			echo "$line_item"
		fi
	done < "$pokemon_submenu_file"

}


display_pokemon_menu() {


    IFS_OLD=$IFS
    IFS=""
    count=0;
    while read -r line; do
        ((count++))
        divisible_four=$(( $count % 4 ))
        if [ "$divisible_four" -eq 0 ]; then
            : # no-op command
        else
            upper_limit_selection=$(( $pokemon_menu_position + 1 ))
            if [ "$count" -ge "$pokemon_menu_position" -a "$count" -le "$upper_limit_selection" ]; then
                echo $hiOn $line $hiOff
            else
                echo $line
            fi  
        fi  
    done < "$pokemon_menu_file"
    IFS=$IFS_OLD
}


select_menu_item(){


	count=0
	while read line_item HM_id; do
		((count++))
		if [ "$count" -eq "$where_selection_is" ]; then
			if [ "${#HM_id}" -gt 0 ]; then
				# This is where the script for a particular HM move would be called. .
				echo "temp dev - $HM_id"
				sleep 2
			else
				[[ "$line_item" = "STATS" ]] &&  bash "menu_files/pokemon_files/stats.sh"
				[[ "$line_item" = "SWITCH" ]] && bash "menu_files/pokemon_files/switch.sh" ; rm "$pokemon_submenu_file"
				[[ "$line_item" = "CANCEL" ]] &&  rm "$pokemon_submenu_file" ; exit 
			fi
		fi

	done < "$pokemon_submenu_file"
}


while :
do

    clear
    keep_selection_in_range "$where_selection_is" "$selection_adjuster"
    display_pokemon_menu
	echo " "
    display_submenu
    read -n1 input < /dev/tty
    case $input in
    w) where_selection_is=$(( $where_selection_is -1 )) ;;
    s) where_selection_is=$(( $where_selection_is +1 )) ;;
    d) select_menu_item ;;
    a) clear ; rm "$pokemon_submenu_file" ; exit ;;
    esac
done

