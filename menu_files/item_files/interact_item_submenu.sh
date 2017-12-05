#!/bin/bash

item_tools="${HOME}/text_dungeon/menu_files/item_files/item_tools.sh"
source "$item_tools"
menu_tools="${HOME}/text_dungeon/menu_files/menu_tools.sh"
source "$menu_tools"
item_submenu_file="${HOME}/text_dungeon/menu_files/item_files/item_submenu"
where_selection_is_item_submenu_file="${HOME}/text_dungeon/menu_files/item_files/where_selection_is_item_submenu"
toss_script="${HOME}/text_dungeon/menu_files/item_files/toss.sh"
use_script="${HOME}/text_dungeon/menu_files/item_files/use.sh"
menu_height=$( wc -l < "$item_submenu_file"  )
selection_adjuster=1 # used for keeping selection in range
where_selection_is=1 # used exclusively for deciding where we are on the item submenu
lines_before_selection=$1 # lines_before_selection and lines_after_selection are used in item_tools.sh, specifically display_inventory_items when it calls
lines_after_selection=$2

select_item_submenu_option(){


	[[ $where_selection_is == 1 ]] && bash "$use_script"
	[[ $where_selection_is == 2 ]] && bash "$toss_script" $lines_before_selection $lines_after_selection # we need to solve this lines_before_selection and lines_after_selection passing issue.

}

while :
do
	clear
	get_where_selection_is_item_menu
	# to prevent conflicts with multiple scripts using the $where_selection_is variable, we provide display_inventory_items with an argument of what the last selection for the parent item menu when we called this script.
	display_inventory_items "$where_selection_is_item_menu"
	keep_selection_in_range "$where_selection_is" "$selection_adjuster"
	# here is where we should have a script or function that verifies whether the item brings up a submenu or not.
	display_submenu "$where_selection_is" # this is dodgey, this variable is used everywhere
	read -n1 input < /dev/tty
	case $input in
	w) where_selection_is=$(( $where_selection_is - 1 )) ;;
	s) where_selection_is=$(( $where_selection_is + 1)) ;;
	# we need where_selection_is in file form so we can read it in item_tools.sh
	d) echo "$where_selection_is" > "$where_selection_is_item_submenu_file" ; select_item_submenu_option ;;
	a) clear ; exit ;;
	esac
done


