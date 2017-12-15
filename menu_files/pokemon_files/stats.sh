#!/bin/bash

source "generic_tools/tools.sh" # calculate_whitespace is sourced from here
pokemon_art_path="pokemon_database/art"
moves_tab_file="pokemon_database/common/moves/moves.tab"
where_selection_is_pokemon_menu_file="menu_files/pokemon_files/where_selection_is_pokemon_menu"
owned_pokemon="character_files/owned_pokemon"
while read value; do
	pokemon_menu_hidden_values_line="$(( $value + 2 ))"
done < "$where_selection_is_pokemon_menu_file"
pokemon_menu_file="/dev/shm/pokemon_menu"
blockOne="/dev/shm/blockOne"
blockTwo="/dev/shm/blockTwo"
blockThree="/dev/shm/blockThree"
blockFour="/dev/shm/blockFour"
blockFive="/dev/shm/blockFive"
whitespace_character=" "

# clean up
[[ -e "$blockOne" ]] && rm "$blockOne"
[[ -e "$blockTwo" ]] && rm "$blockTwo"
[[ -e "$blockThree" ]] && rm "$blockThree"
[[ -e "$blockFour" ]] && rm "$blockFour"
[[ -e "$blockFive" ]] && rm "$blockFive"


# get the ID of the pokemon that is currently selected in the pokemon menu:
count=0
IFS_OLD=$IFS
# space
IFS=" "
while read cmoveOne cmoveTwo cmoveThree cmoveFour cpokemonUniqueID; do
	((count++))
	if [ "$count" -eq "$pokemon_menu_hidden_values_line" ]; then
		selectedPokemon="$cpokemonUniqueID"
	fi
done < "$pokemon_menu_file"
unset count
IFS=$IFS_OLD


pokemonFileToRead="${owned_pokemon}/${selectedPokemon}.*"
read_pokemon_file $pokemonFileToRead
pokemon_Art="${pokemon_art_path}/${pokemonID}.art"
artLength="$( wc -L < "$pokemon_Art" )"


# calculates the number of empty lines that should be on top of a given block so that the block sits level with the pokemon art. Only used for blockOne and blockSomethingIForgot
calculate_topSpace(){

block=$1
artHeight=$( wc -l < "$pokemon_Art" )
blockHeight=$( wc -l < "$block" )
topSpace=$(( $artHeight - $blockHeight ))
local count=0
while [ "$count" -le "$topSpace" ]; do
	((count++))
	echo -e "\n$(cat "$block")" > "$block"
done
}

# layout:
# art        blockOne
# blockTwo   blockThree
# See text_dungeon/pokemon_database/art/temp_stat_drawing/statscreenOne for a real example of what this produces.


#blockOne (stat screen one): 
touch "$blockOne"
calculate_whitespace 16 ${#pokemonName} $whitespace_character
echo "       ${pokemonName}${whitespace}|" >> "$blockOne"
calculate_whitespace 12 ${#level} $whitespace_character
echo "         L:${level}${whitespace}|" >> "$blockOne"
draw_HPbar $currentHP $HP 10
echo "      hp:${populated_HPbar}${unpopulate_HPbar}    |" >> "$blockOne"
HP_value_display="${currentHP} / ${HP}"
calculate_whitespace 15 ${#HP_value_display} $whitespace_character
echo "        ${HP_value_display}${whitespace}|" >> "$blockOne"
[[ $majorAilment = 0 ]] && majorAilment="OK"
calculate_whitespace 10 ${#majorAilment} $whitespace_character
echo "     STATUS/ ${majorAilment}${whitespace}|" >> "$blockOne"
echo "   <-------------------0" >> "$blockOne"
echo " " >> "$blockOne"
calculate_topSpace "$blockOne"


#blockTwo (stat screen one)
touch "$blockTwo"
half_artLength="$( echo "scale=1;${artLength} / 2" | bc  )"
half_artLength="$( echo "${half_artLength} / 1" | bc )"
calculate_whitespace $(( $half_artLength - 2 )) 6 $whitespace_character
echo "${whitespace}No.${pokemonID}${whitespace}" >> "$blockTwo"
calculate_whitespace $(( $artLength - 1 )) 0 "-"
echo "O${whitespace}O" >> "$blockTwo"
attackDisplay="ATTACK  ${attack}"
calculate_whitespace $(( $artLength - 10 )) ${#attackDisplay} " "
echo "|         $attackDisplay${whitespace}|" >> "$blockTwo"
defenseDisplay="DEFENSE ${defense}"
calculate_whitespace $(( $artLength - 10 )) ${#defenseDisplay} " "
echo "|         $defenseDisplay${whitespace}|" >> "$blockTwo"
speedDisplay="SPEED   ${speed}"
calculate_whitespace $(( $artLength - 10 )) ${#speedDisplay} " "
echo "|         $speedDisplay${whitespace}|" >> "$blockTwo"
specialDisplay="SPECIAL ${special}"
calculate_whitespace $(( $artLength - 10 )) ${#specialDisplay} " "
echo "|         $specialDisplay${whitespace}|" >> "$blockTwo"
calculate_whitespace $(( $artLength - 1 )) 0 "-"
echo "O${whitespace}O" >> "$blockTwo"


#blockThree (stat screen one)
touch "$blockThree"
echo " " >> "$blockThree"
echo "TYPE 1/ ${typeOne}" >> "$blockThree"
echo "TYPE 2/ ${typeTwo}" >> "$blockThree"
echo " " >> "$blockThree"
echo "IDNo/ ${pokemonUniqueID}" >> "$blockThree"
echo "OT  / PLAYERNAME" >> "$blockThree"
echo " " >> "$blockThree"

# display statscreenOne
paste "$pokemon_Art" "$blockOne"
paste "$blockTwo" "$blockThree"

# wait for input before displaying the second screen
read -n1 input < /dev/tty
clear


# The code below deals with displaying statscreenTwo
# layout:
# art        blockFour
# blockFive  [empty]
# See howto/statscreenTwo for a real example of what this produces.


#blockFour
touch "$blockFour"
whitespace_character=" "
calculate_whitespace 16 ${#pokemonName} $whitespace_character
echo "       ${pokemonName}${whitespace}|" >> "$blockFour"
ExpForDisplay="EXP POINT"
calculate_whitespace 16 ${#ExpForDisplay} $whitespace_character
echo "       ${ExpForDisplay}${whitespace}|" >> "$blockFour"
calculate_whitespace 22 ${#currentExp} $whitespace_character
echo "${whitespace}${currentExp} |" >> "$blockFour"
echo "       LEVEL UP        |" >> "$blockFour"
ExpToNLevel=$(( $nextLevelExp - $currentExp ))
nextLevel=$(( $level + 1 ))
levelUpForDisplay="${ExpToNLevel} to L:${nextLevel}"
calculate_whitespace 16 ${#levelUpForDisplay} $whitespace_character
echo "       ${levelUpForDisplay}${whitespace}|" >> "$blockFour"
echo "   <-------------------0" >> "$blockFour"
echo " " >> "$blockFour"
calculate_topSpace "$blockFour"


# Get move names
IFS_OLD=$IFS
# IFS = tab
IFS="	"
# don't get PP from here. Remember PP can be increased at the pokemon level. Getting moveOnePPMax from here is a hack. For some absolutely freaky reason, moveOnePPMax can't be read from the pokemon file (see line 47). Everything else reads okay, just not this one value in particular. Fuck knows. Getting any other value from that file is fine.
while read moveID moveName HM_TM defaultPP moveType accuracy power category; do
	case $moveID in
	"$moveOne") moveOneName="$moveName" && moveOnePPMax="$defaultPP" ;;
	"$moveTwo") moveTwoName="$moveName" ;;
	"$moveThree") moveThreeName="$moveName" ;;
	"$moveFour") moveFourName="$moveName" ;;
	esac
done < "$moves_tab_file"
IFS=$IFS_OLD

#blockFive
touch "$blockFive"
half_artLength="$( echo "scale=1;${artLength} / 2" | bc  )"
half_artLength="$( echo "${half_artLength} / 1" | bc )"
# white space to surround the No.ID part
calculate_whitespace $(( $half_artLength - 2 )) 6 " "
echo "${whitespace}No.${pokemonID}${whitespace}" >> "$blockFive"
calculate_whitespace $(( $artLength - 1 )) 0 "-"
echo "O${whitespace}O" >> "$blockFive"

# Move One
moveNameOneDisplay="|         ${moveOneName}"
# Get the whitespace that goes between move name and pp
calculate_whitespace 25 ${#moveNameOneDisplay} " "
moveNameOneDisplay="|         ${moveOneName}${whitespace}"
ppOneDisplay="${moveNameOneDisplay}pp ${moveOnePP} / ${moveOnePPMax}" 
# get whitespace to go to the right of the pp part
calculate_whitespace ${artLength} ${#ppOneDisplay} " "
echo "${ppOneDisplay}${whitespace}|" >> "$blockFive"

# Move Two
if [ "$moveTwo" -ne 0 ]; then
	moveNameTwoDisplay="|         ${moveTwoName}"
	# Get the whitespace that goes between move name and pp
	calculate_whitespace 25 ${#moveNameTwoDisplay} " "
	moveNameTwoDisplay="|         ${moveTwoName}${whitespace}"
	ppTwoDisplay="${moveNameTwoDisplay}pp ${moveTwoPP} / ${moveTwoPPMax}" 
	# get whitespace to go to the right of the pp part
	calculate_whitespace ${artLength} ${#ppTwoDisplay} " "
	echo "${ppTwoDisplay}${whitespace}|" >> "$blockFive"
else
	calculate_whitespace $(( $artLength - 1 )) 0 " "
	echo "|${whitespace}|" >> "$blockFive"
fi

# Move Three
if [ "$moveThree" -ne 0 ]; then
	moveNameThreeDisplay="|         ${moveThreeName}"
	# Get the whitespace that goes between move name and pp
	calculate_whitespace 25 ${#moveNameThreeDisplay} " "
	moveNameThreeDisplay="|         ${moveThreeName}${whitespace}"
	ppThreeDisplay="${moveNameThreeDisplay}pp ${moveThreePP} / ${moveThreePPMax}" 
	# get whitespace to go to the right of the pp part
	calculate_whitespace ${artLength} ${#ppThreeDisplay} " "
	echo "${ppThreeDisplay}${whitespace}|" >> "$blockFive"
else
	calculate_whitespace $(( $artLength - 1 )) 0 " "
	echo "|${whitespace}|" >> "$blockFive"
fi

# Move four
if [ "$moveFour" -ne 0 ]; then
	moveNameFourDisplay="|         ${moveFourName}"
	# Get the whitespace that goes between move name and pp
	calculate_whitespace 25 ${#moveNameFourDisplay} " "
	moveNameFourDisplay="|         ${moveFourName}${whitespace}"
	ppFourDisplay="${moveNameFourDisplay}pp ${moveFourPP} / ${moveFourPPMax}" 
	# get whitespace to go to the right of the pp part
	calculate_whitespace ${artLength} ${#ppFourDisplay} " "
	echo "${ppFourDisplay}${whitespace}|" >> "$blockFive"
else
	calculate_whitespace $(( $artLength - 1 )) 0 " "
	echo "|${whitespace}|" >> "$blockFive"
fi

# Now seal off the bottom
calculate_whitespace $(( $artLength - 1 )) 0 "-"
echo "O${whitespace}O" >> "$blockFive"


paste "$pokemon_Art" "$blockFour"
cat "$blockFive"

read -n1 input < /dev/tty

# now we go back to the regular pokemon menu. No submenu is opened after doing 'stats'.
exit

