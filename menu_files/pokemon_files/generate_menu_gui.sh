#!/bin/bash

# this file generates what is mostly the gui component of the pokemon menu. the output of this file will look similar to the example immediately below:
#0 BULBASAUR                L:5    
#0 HP:#############-------  13 / 20
# there's also another non-gui component of the output file that gets created immediately below what you see above. This line contains the pokemonUniqueID and the pokemon's moves (so far.)

pokemon_in_inventory="${HOME}/text_dungeon/character_files/pokemon_in_inventory.csv"
owned_pokemon="${HOME}/text_dungeon/character_files/owned_pokemon"
pokemon_menu_file="/dev/shm/pokemon_menu"

generate_pokemon_menu(){

	[[ -e "$pokemon_menu_file" ]] && rm "$pokemon_menu_file"
	# first get the location of the source pokemon files for the pokemon that will appear in this menu
	pokemon_count=0
	declare -a pokemon_file_location
	while read pokemon_file; do

		((pokemon_count++))
		pokemon_file_location[$pokemon_count]="${owned_pokemon}/${pokemon_file}"
	done < "$pokemon_in_inventory"

	OLD_IFS=$IFS
	# tabs baby
	IFS="	"
	countdown=0
	declare -a pokemonIDARR
	declare -a pokemonUniqueIDARR
	declare -a pokemonNameARR
	declare -a pokemonGivenNameARR
	declare -a inventoryStatusARR
	declare -a currentHPARR
	declare -a levelARR
	declare -a typeOneARR
	declare -a typeTwoARR
	declare -a moveOneARR
	declare -a moveTwoARR
	declare -a moveThreeARR
	declare -a moveFourARR
	declare -a moveOnePPARR
	declare -a moveTwoPPARR
	declare -a moveThreePPARR
	declare -a moveFourPPARR
	declare -a moveOnePPMaxARR
	declare -a moveTwoPPMaxARR
	declare -a moveThreePPMaxARR
	declare -a moveFourPPMaxARR
	declare -a HPARR
	declare -a attackARR
	declare -a defenseARR
	declare -a specialARR
	declare -a speedARR
	declare -a majorAilmentARR
	declare -a levellingRateARR
	declare -a catchRateARR
	declare -a baseExpYieldARR
	declare -a currentExpARR
	declare -a nextLevelExpARR

	while [ "$countdown" -lt "$pokemon_count" ]; do

		((countdown++))		
		while read -r pokemonID_ pokemonUniqueID_ pokemonName_ pokemonGivenName_ inventoryStatus_ currentHP_ level_ typeOne_ typeTwo_ moveOne_ moveTwo_ moveThree_ moveFour_ moveOnePP_ moveTwoPP_ moveThreePP_ moveFourPP_ moveOnePPMAX_ moveTwoPPMax_ moveThreePPMax_ moveFourPPMax_ HP_ attack_ defence_ special_ speed_ majorAilment_ levellingRate_ catchRate_ baseExpYield_ currentExp_ nextLevelExp_; do
			pokemonIDARR[$countdown]="$pokemonID_"
			pokemonUniqueIDARR[$countdown]="$pokemonUniqueID_"
			pokemonNameARR[$countdown]="$pokemonName_"
			pokemonGivenNameARR[$countdown]="$pokemonGivenName_"
			inventoryStatusARR[$countdown]="$inventoryStatus_"
			currentHPARR[$countdown]="$currentHP_"
			levelARR[$countdown]="$level_"
			typeOneARR[$countdown]="$typeOne_"
			typeTwoARR[$countdown]="$typeTwo_"
			moveOneARR[$countdown]="$moveOne_"
			moveTwoARR[$countdown]="$moveTwo_"
			moveThreeARR[$countdown]="$moveThree_"
			moveFourARR[$countdown]="$moveFour_"
			moveOnePPARR[$countdown]="$moveOnePP_"
			moveTwoPPARR[$countdown]="$moveTwoPP_"
			moveThreePPARR[$countdown]="$moveThreePP_"
			moveFourPPARR[$countdown]="$moveFourPP_"
			moveOnePPMaxARR[$countdown]="$moveOnePPMax_"
			moveTwoPPMaxARR[$countdown]="$moveTwoPPMax_"
			moveThreePPMaxARR[$countdown]="$moveThreePPMax_"
			moveFourPPMaxARR[$countdown]="$moveFourPPMax_"
			HPARR[$countdown]="$HP_"
			attackARR[$countdown]="$attack_"
			defenceARR[$countdown]="$defence_"
			specialARR[$countdown]="$special_"
			speedARR[$countdown]="$speed_"
			majorAilmentARR[$countdown]="$majorAilment_"
			levellingRateARR[$countdown]="$levellingRate_"
			catchRateARR[$countdown]="$catchRate_"
			baseExpYieldARR[$countdown]="$baseExpYield_"
			currentExpARR[$countdown]="$currentExp_"
			nextLevelExpARR[$countdown]="$nextLevelExp_"
		done < "${pokemon_file_location[$countdown]}"
	IFS=$OLD_IFS
	done 
	unset countdown


	count=1;
	while [ "$count" -le "$pokemon_count" ]; do
		# 24 characters are the max characters this function allows for a pokemon's name
		calculate_whitespace(){
			whitespace_length=$((25 - ${#pokemonGivenNameARR[$count]}))
			whitespace="$( head -c "$whitespace_length" < /dev/zero | tr '\0' ' ' )"
		}
		# this is the whitespace that appears between the pokemon name and the level display
		calculate_whitespace

		draw_HPbar(){
			filled_fraction=$(echo "${currentHPARR[$count]} / ${HPARR[$count]}" | bc -l)
			filled_length=$( echo "($filled_fraction * 20)/1" | bc)
			populated_HPbar="$( head -c "$filled_length" < /dev/zero | tr '\0' '#' )"
			unfilled_length=$(( 20 - $filled_length ))
			# unpopulated_HPbar = 0 breaks things!
			[[ $unfilled_length -gt 0 ]] && unpopulated_HPbar="$( head -c "$unfilled_length" < /dev/zero | tr '\0' '-' )" || unpopulated_HPbar=;
			
		}
		# eg. hp = 2/20 then HPbar will be "##------------------"
		draw_HPbar

		get_ailment(){
			# ye ol whitespace ailment
			[[ ${majorAilmentARR[$count]} == 0 ]] && ailment="$( head -c4 < /dev/zero | tr '\0' ' ' )"
			[[ ${majorAilmentARR[$count]} == 1 ]] && ailment="BRN"
			[[ ${majorAilmentARR[$count]} == 2 ]] && ailment="FRZ"
			[[ ${majorAilmentARR[$count]} == 3 ]] && ailment="PAR"
			# 4 = poisoned, 5 = badly poisoned. same gui component but different rules mechanics.
			[[ ${majorAilmentARR[$count]} == 4 ]] && ailment="PSN"
			[[ ${majorAilmentARR[$count]} == 5 ]] && ailment="PSN"
			[[ ${majorAilmentARR[$count]} == 6 ]] && ailment="SLP"
		}

		# get ailment for display
		get_ailment
		echo " " >> $pokemon_menu_file
		echo "0 ${pokemonGivenNameARR[$count]}${whitespace}L:${levelARR[$count]}${ailment}" >> $pokemon_menu_file
		echo "0 HP:${populated_HPbar}${unpopulated_HPbar}  ${currentHPARR[$count]} / ${HPARR[$count]}" >> $pokemon_menu_file
		# we expect the output of the code above to match the example on lines 4 and 5 of this file.

		# the moves below are space seperated.
		# we use these in interact_pokemon_menu.sh to generate the submenu that potentially contains outside-of-battle options for HM type moves.
		echo "${moveOneARR[$count]} ${moveTwoARR[$count]} ${moveThreeARR[$count]} ${moveFourARR[$count]} ${pokemonUniqueIDARR[$count]}" >> $pokemon_menu_file

		unset ailment
		((count++))
	done	
	
}

generate_pokemon_menu
