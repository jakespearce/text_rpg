#!/bin/bash
# Here we deal with the "tossing" of items ie. throwing an item away


item_tools="${HOME}/text_dungeon/menu_files/item_files/item_tools.sh"
source "$item_tools"
menu_tools="${HOME}/text_dungeon/menu_files/menu_tools.sh"
source "$menu_tools"
item_inventory_file_path="${HOME}/text_dungeon/menu_files/item_files/inventory_items.tab"
temp_item_inventory_file_path="${HOME}/text_dungeon/menu_files/item_files/temp_inventory_items.tab"
lines_before_selection=$1 #TODO so far lines_before_selection and lines_after_selection are created and changed via item_menu. They are passed on to item_submenu. They are then passed here. They are passed as script arguments. This is very unsexy and upsetting, it should be fixed.
lines_after_selection=$2
menu_height=1 #TODO this is just a placeholder so that reposition_item_menu_window in item_tools.sh doesn't break. It doesn't matter what value it is, as long as it's an integer. This is saddening and needs fixing.
tossQuantity=1


retain_key_item(){

	if [ "$keyItem" -eq 1 ]; then
		echo "O-------------------------------O"
		echo "| That's too important to toss! |"
		echo "O-------------------------------O"

		read -n1 input < /dev/tty

		exit 0
	fi
}


# this function ensures that we 'loop' through the quantity to toss
adjust_toss_quantity(){

	[[ $tossQuantity -gt $itemQuantity ]] && tossQuantity=1
	[[ $tossQuantity -eq 0 ]] && tossQuantity="$itemQuantity"
}


display_toss_quantity(){

	# test below adds whitespace to tossQuantity if the value is less than 10 ie. string length is 1.
	[[ ${#tossQuantity} == 1  ]] && tossQuantityforDisplay="${tossQuantity} " || tossQuantityforDisplay="$tossQuantity"

	echo "O---------------------O"
	echo "| Toss how many?" $hiOn  $tossQuantityforDisplay $hiOff "|"
	echo "O---------------------O"
}


# reads the inventory file and rewrites it, writing in the item quantity change for the item we just tossed.
# if we've tossed all of that particular item then just don't bother writing that item line into the new file.
toss_items(){

	quantityRemaining=$(( $itemQuantity - $tossQuantity ))
	count=0
	[[ ! -e "$temp_item_inventory_file_path" ]] && touch "$temp_item_inventory_file_path"
	IFS_OLD=$IFS
	IFS='	' # tab
	while read itemID_inventory itemName_inventory context_inventory quantity_inventory submenu_inventory; do
		((count++))

		if [ "$itemID" -eq "$itemID_inventory" ]; then
			if [ "$quantityRemaining" -eq 0 ]; then
				:
			else
				echo "${itemID_inventory}	${itemName_inventory}	${context_inventory}	${quantityRemaining}	${submenu_inventory}" >> "$temp_item_inventory_file_path"
			fi
		else
			echo "${itemID_inventory}	${itemName_inventory}	${context_inventory}	${quantity_inventory}	${submenu_inventory}" >> "$temp_item_inventory_file_path"
		fi

	IFS=$IFS_OLD
	done < "$item_inventory_file_path"
	
	mv "$temp_item_inventory_file_path" "$item_inventory_file_path"
}


while :
do
	clear
	get_where_selection_is_item_menu
	get_where_selection_is_item_submenu
	display_inventory_items "$where_selection_is_item_menu"
	display_submenu "$where_selection_is_item_submenu"
	get_item_data "$where_selection_is_item_menu" # get data about the item we have selected.
	retain_key_item
	display_toss_quantity
	read -n1 input < /dev/tty
	case $input in
	w) tossQuantity=$(( $tossQuantity + 1 )) ; adjust_toss_quantity ;;
	s) tossQuantity=$(( $tossQuantity - 1  )) ; adjust_toss_quantity ;;
	# step below kills the item_submenu script as well as this script, after tossing.
	d) toss_items ; item_submenu_PID=$( ps aux | grep -v grep | grep 'item_files/interact_item_submenu' | awk {'print $2'} ) ; kill "$item_submenu_PID"  ; exit ;; 
	a) exit ;;
	esac
done
