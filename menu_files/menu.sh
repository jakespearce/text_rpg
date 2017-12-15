#!/bin/bash

source menu_files/menus.cfg
source generic_tools/tools.sh
menu_tools="menu_files/menu_tools.sh"
selection_adjuster=1
source "$menu_tools"

# menu files filepath
menu_files="menu_files"

# always start with where_selection_is at 1, so we're at the top of any menu we land on
where_selection_is=1

# $current_menu will be a path to a menu file, determined by menus.cfg
# this is purely the gui component of the main menu.
current_menu=${menu[$menu_in_view]}

menu_height=$( wc -l < $current_menu )
cat $current_menu > /dev/shm/marked_menu


# the menu item that is currently selected has 'selected' appended to the menu in marked_menu. when we read this line we turn highlighting on so it appears highlighted.
show_menu(){


	while read menu_item item_number selected; do

    	if [[ "$selected" == "selected" ]]; then
      		echo "$hiOn $menu_item $hiOff"
    	else
      		echo "$menu_item"
    	fi
  	done < /dev/shm/marked_menu
}


# this doesn't refresh menu for user, it just marks a menu line as 'selected' and writes that to marked_menu.
refresh_menu(){


  	local count=;
  	while read menu_line; do

    	((count++))
    	if [ "$count" -eq "$where_selection_is" ]; then
      		echo $menu_line "selected"
    	else
      		echo $menu_line
    	fi

  	done < $current_menu > /dev/shm/marked_menu
}


# this is where the user hits d and opens a sub-menu. 
# essentially we: grab the item_number (a value in the 2nd column of any menu file)
# the item number tells us which menu to load next. deciding which file to load is decided by menus.cfg
# eg. item_numer=8332. menus.cfg loads menu[8332]. menu[8332] points to a menu file. 
# THE ABOVE IS POTENTIALLY DEPRECATED but I like the description, a similar system could be put to better use elsewhere.
select_menu_item(){


  	local count=;

  	while read menu_line item_number; do

    ((count++))
   	if [ $where_selection_is == $count ]; then

			[[ $item_number == 1 ]] && bash ${menu_files}/pokedex_files/pokedex.sh
			[[ $item_number == 2 ]] && bash ${menu_files}/pokemon_files/interact_pokemon_menu.sh
			[[ $item_number == 3 ]] && bash ${menu_files}/item_files/interact_item_menu.sh
			# TODO: THE REST
    	fi
  	done < $current_menu
}


while :
do

	clear
 	keep_selection_in_range "$where_selection_is" "$selection_adjuster"
  	refresh_menu
  	show_menu

  	read -n1 input
  	case $input in
    	w|W) where_selection_is=$(( $where_selection_is - 1 )) ;;
    	s|S) where_selection_is=$(( $where_selection_is + 1 )) ;;
    	# empty string is enter key
    	""|d) select_menu_item ;;
    	b|a) change_conf_value $menu_config "menu_in_view" 0 ; clear ; exit ;;
  	esac

done

