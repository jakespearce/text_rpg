#!/bin/bash


where_selection_is=1 # we can set this value to whatever's in where_selection_is_item if landing on 1 whenever this script is called is for some reason bad.
item_tools="${HOME}/text_dungeon/menu_files/item_files/item_tools.sh"
source "$item_tools"
menu_tools="${HOME}/text_dungeon/menu_files/menu_tools.sh"
source "$menu_tools"
item_submenu_script="${HOME}/text_dungeon/menu_files/item_files/interact_item_submenu.sh"
where_selection_is_file_item_menu="${HOME}/text_dungeon/menu_files/item_files/where_selection_is_items"
item_menu_file="${HOME}/text_dungeon/menu_files/item_files/inventory_items.tab"
menu_height=$( wc -l < "$item_menu_file"  )
selection_adjuster=1 # used for keeping selection in range
lines_before_selection=1 # lines_before_selection = Before, lines_after_selection = in front. We see 7 menu items at a time. When we open the menu we see all items between 1 and 7.
lines_after_selection=7

while :
do
	clear
	menu_height=$( wc -l < "$item_menu_file"  ) # for when we TOSS an item we need to work out menu height again.
	keep_selection_in_range "$where_selection_is" "$selection_adjuster"
	display_inventory_items "$where_selection_is"
	read -n1 input < /dev/tty
	case $input in
	w) where_selection_is=$(( $where_selection_is - 1)) ;;
	s) where_selection_is=$(( $where_selection_is + 1)) ;;
	# we need where_selection_is in file form so we can read it in item_tools.sh
	# TODO submenu shouldn't open for certain items eg. Bicycle. Should this functionality be here or in the submenu script?
	d) echo "$where_selection_is" > "$where_selection_is_file_item_menu" ; bash "$item_submenu_script" "$lines_before_selection" "$lines_after_selection" ;;
	a) clear ; exit ;;
	esac
done

