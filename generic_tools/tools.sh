#!bin/bash

# changes a key value in a config file to a value we specify.
# usage: change_conf_value $config_file_path $key_to_change $new_value
# eg. change_conf_value character_files/character.cfg "level" 99
change_conf_value(){

	config_file_path=$1
  	key_to_change=$2
  	new_value=$3

  	sed -i "s/\($key_to_change *= *\).*/\1$new_value/" $config_file_path
}


# $whitespace_max is the total characters from where our string starts and where we want our potentially added whitespace to end.. given $string_length we append 'whitespace' characters to the string until our string length + our whitespace = whitespace max. Oh, and the whitespace doesn't HAVE to be whitespace.
calculate_whitespace(){

    whitespace_max=$1
    string_length=$2
	whitespace_character=$3
    whitespace_length=$(( ${whitespace_max} - ${string_length} ))
    whitespace="$( head -c "$whitespace_length" < /dev/zero | tr '\0' "$whitespace_character" )"
}

draw_HPbar(){
		currentHP=$1
		maxHP=$2
		barLength=$3
        filled_fraction=$(echo "$currentHP / $maxHP" | bc -l)
        filled_length=$( echo "($filled_fraction * $barLength)/1" | bc)
        populated_HPbar="$( head -c "$filled_length" < /dev/zero | tr '\0' '#' )"
        unfilled_length=$(( $barLength - $filled_length ))
        # unpopulated_HPbar = 0 breaks things!
        [[ $unfilled_length -gt 0 ]] && unpopulated_HPbar="$( head -c "$unfilled_length" < /dev/zero | tr '\0' '-' )" || unpopulated_HPbar=;
    
}


# reads a pokemon file and extracts values to variables.
read_pokemon_file(){

	fileToRead=$1	
	IFS_OLD=$IFS
	#IFS = TAB
	IFS="	"

        while read -r pokemonID_ pokemonUniqueID_ pokemonName_ pokemonGivenName_ inventoryStatus_ currentHP_ level_ typeOne_ typeTwo_ moveOne_ moveTwo_ moveThree_ moveFour_ moveOnePP_ moveTwoPP_ moveThreePP_ moveFourPP_ moveOnePPMax_ moveTwoPPMax_ moveThreePPMax_ moveFourPPMax_ HP_ attack_ defence_ special_ speed_ majorAilment_ levellingRate_ catchRate_ baseExpYield_ currentExp_ nextLevelExp_; do
            pokemonID="$pokemonID_"
            pokemonUniqueID="$pokemonUniqueID_"
            pokemonName="$pokemonName_"
            pokemonGivenName="$pokemonGivenName_"
            inventoryStatus="$inventoryStatus_"
            currentHP="$currentHP_"
            level="$level_"
            typeOne="$typeOne_"
            typeTwo="$typeTwo_"
            moveOne="$moveOne_"
            moveTwo="$moveTwo_"
            moveThree="$moveThree_"
            moveFour="$moveFour_"
            moveOnePP="$moveOnePP_"
            moveTwoPP="$moveTwoPP_"
            moveThreePP="$moveThreePP_"
            moveFourPP="$moveFourPP_"
            moveOnePPMax="$moveOnePPMax_"
            moveTwoPPMax="$moveTwoPPMax_"
            moveThreePPMax="$moveThreePPMax_"
            moveFourPPMax="$moveFourPPMax_"
            HP="$HP_"
            attack="$attack_"
            defense="$defence_"
            special="$special_"
            speed="$speed_"
            majorAilment="$majorAilment_"
            levellingRate="$levellingRate_"
            catchRate="$catchRate_"
            baseExpYield="$baseExpYield_"
			currentExp="$currentExp_"
			nextLevelExp="$nextLevelExp_"
        done < "$fileToRead"

    IFS=$OLD_IFS


}


rolling_dialogue(){

    lineToStartAt=$1
    lineToEndAt=$2
    dialogueFile=$3
    whitespace_character=" "

    local count=0

        while read line; do
            ((count++)) 
                
            if [ $count -ge $lineToStartAt ]; then  
				
                stringLength=${#line}
				# First work out half the total whitespace length
				halfTotalWhiteLength=$( echo "scale=1; ( 40 - $stringLength ) / 2" | bc )

				# If half the total whitespace length is not an integer then 
				if [[ $halfTotalWhiteLength =~ [0-9]\.[5] ]]; then
					# rightHandWhiteSpace rounds up to give us more whitespace on the right
					rightHandWhiteSpaceLength=$( echo "$halfTotalWhiteLength / 1 + 1" | bc )
					leftHandWhiteSpaceLength=$( echo "$halfTotalWhiteLength / 1" | bc )

					# For RHS first:
					# stringLength redefined to be total length of text string plus LHS
					stringLengthForRHS=$(( $stringLength + $leftHandWhiteSpaceLength ))
					calculate_whitespace 40 "$stringLengthForRHS" "$whitespace_character"
					rightHandWhiteSpace="$whitespace"

					# For LHS next:
					# stringLength redefined to be the total length of text string plus RHS
					stringLengthForLHS=$(( $stringLength + $rightHandWhiteSpaceLength ))
					calculate_whitespace 40 "$stringLengthForLHS" "$whitespace_character"
					leftHandWhiteSpace="$whitespace"
				else
					halfTotalWhiteLength=$( echo "$halfTotalWhiteLength / 1" | bc )
					totalStringLength=$(( $stringLength + $halfTotalWhiteLength ))
                	calculate_whitespace 40 $totalStringLength "$whitespace_character"
					leftHandWhiteSpace="$whitespace"
					rightHandWhiteSpace="$whitespace"
				fi
				clear
				cat "${map_rw_path}/marked_map_output"
                echo "o----------------------------------------o"
                echo "|                                        |"
                echo "|${leftHandWhiteSpace}${line}${rightHandWhiteSpace}|"
                echo "|                                        |"
                echo "o----------------------------------------o"
                read -n1 input < /dev/tty
                clear
                cat "${map_rw_path}/marked_map_output"
                [[ $count -eq $lineToEndAt ]] && return 1
        fi  

        done < "$dialogueFile"

}





