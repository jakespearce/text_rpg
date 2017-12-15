#!/bin/bash

inventory_items_path="menu_files/item_files/inventory_items.tab"
item_submenu_file="menu_files/item_files/item_submenu"
hiOn=$( tput smso )
hiOff=$( tput rmso )
where_selection_is_file_item_menu="menu_files/item_files/where_selection_is_items"
where_selection_is_file_item_submenu="menu_files/item_files/where_selection_is_item_submenu"


get_where_selection_is_item_menu(){


	while read value; do
		where_selection_is_item_menu="$value"
	done < "$where_selection_is_file_item_menu"
}


get_where_selection_is_item_submenu(){


	while read value; do
		where_selection_is_item_submenu="$value"
	done < "$where_selection_is_file_item_submenu"
}


reposition_item_menu_window(){


    if [ "$inventory_item_selection" -lt "$lines_before_selection" -a "$lines_before_selection" -ne 1 ]; then
        lines_before_selection=$(( $lines_before_selection - 1 ))
        lines_after_selection=$(( $lines_after_selection - 1 ))
    
	# menu height needs to be sourced from the correct place.
    elif [ "$inventory_item_selection" -gt "$lines_after_selection" -a "$lines_after_selection" -ne "$menu_height" ]; then 
        lines_before_selection=$(( $lines_before_selection + 1  ))
        lines_after_selection=$(( $lines_after_selection + 1 ))
    fi 
}


display_inventory_items(){


	inventory_item_selection=$1
	reposition_item_menu_window	# I think we need to provide the values of lines_before_selection and lines_after_selection here for when this function is called from anywhere else but item menu and item submenu, Why does it only work in them circumstances?

	local count=0
	OLD_IFS=$IFS
	IFS="	" # tab
	while read itemID_ itemName_ itemContext_ itemQuantity_ subMenu_ keyItem_; do
		((count++))
		itemName="$itemName_"
		itemID="$itemID_"
		itemQuantity="$itemQuantity_"
		itemContext="$itemContext_"
		subMenu="$subMenu_"
		keyItem="$keyItem_"

		# calculating whitespace is resource-intensive and makes the display flicker :( might have to get smarter with this.
		inventory_whitespace_max=17 # based off the length of 99 Thunder Stones (longest item name and qt. in game)
		item_name_length=${#itemName}
		item_quantity_length=$(( ${#itemQuantity} + 1 )) # + 1 for the x, eg. x99
		[[ $keyItem = 1 ]] && item_quantity_length=0
		inventory_whitespace_length=$(( $inventory_whitespace_max - $item_name_length - $item_quantity_length ))
		inventory_whitespace="$( head -c "$inventory_whitespace_length" < /dev/zero | tr '\0' ' ' )"

		if [ "$count" -ge "$lines_before_selection" -a "$count" -le "$lines_after_selection" ]; then
			if [ "$count" -eq "$inventory_item_selection" ]; then

				case $keyItem in
					0) echo $hiOn "${itemName}${inventory_whitespace}x${itemQuantity}" $hiOff ;;
					1) echo $hiOn "${itemName}${inventory_whitespace}" $hiOff ;; # don't display qty for key items
				esac
			else

				case $keyItem in
					0) echo "${itemName}${inventory_whitespace}x${itemQuantity}" ;;
					1) echo "${itemName}${inventory_whitespace}" ;; # don't display qty for key items
				esac

			fi
		fi

	done < "$inventory_items_path"
	IFS=$IFS_OLD
	unset count
}


# where_selection_is COULD cause conflicts if we're using this in conjunction with another menu such as the pokemon menu.
# when we use an item on a pokemon, we're taken back to the main pokemon menu and we find ourselves at the top of the menu. worth bearing in mind.
display_submenu(){


	submenu_item_selection=$1 # TODO newly added for toss
	local count=0
	while read subMenuOption_; do
		((count++))
		subMenuOption="$subMenuOption_"

		# $where_selection_is_submenu is set in the interact_item_submenu.sh script
		if [ "$submenu_item_selection" -eq "$count" ]; then
			echo $hiOn "$subMenuOption" $hiOff
		else
			echo "$subMenuOption"
		fi

	done < "$item_submenu_file"
}


# what's count doing in this function?
get_item_data(){


	target_item=$1 # this is a number representing how many lines down the inventory_items.tab the target item is
	local count=0
	OLD_IFS=$IFS
	IFS="	" # tab
	while read itemID_ itemName_ itemContext_ itemQuantity_ subMenu_ keyItem_; do
		((count++))
		itemName="$itemName_"
		itemID="$itemID_"
		itemQuantity="$itemQuantity_"
		itemContext="$itemContext_"
		subMenu="$subMenu_"
		keyItem="$keyItem_"
		[[ $count == $target_item ]] && break
	done < "$inventory_items_path"

}


