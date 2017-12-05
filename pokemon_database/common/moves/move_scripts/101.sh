#!/bin/bash
# Attack ID 101 is fly. This is here for testing out the functionality of the moveTicks system. 

source "${HOME}/pokemon/gui/battles/battle_tools.sh"

attackingPokemon="$1"
defendingPokemon="$2"
counterVariableArgument="$3"
attackBeingUsed=101
nameOfAttack="Fly"


# Note: $counterVariable is always going to be 0 when we call the script for the first time.
# The second time the script is called, it's called via the moveTicks file where an argument of 1 is supplied.
# This is when we write to the moveTicks file. This is when the Pokemon flies up high.
if [ $counterVariableArgument -eq 0 ]; then

	echo "We'd also show some flying graphics in here"
	echo "${attackBeingUsed}	1	${attackingPokemon}" > "$moveTicksFile"
	echo "${attackBeingUsed}	1	${attackingPokemon} has been written to moveTicks"


	read_attribute_battleFile "${battle_filetmp_path}/${attackingPokemon}.pokemon"
	> "${battle_filetmp_path}/${attackingPokemon}.pokemon"

	# Set semiInvulnerable = 1 - turn semi invulnerability on
	echo -e "${pokemonID}\t${pokemonUniqueID}\t${pokemonName}\t${level}\t${HP}\t${currentHP}\t${attack}\t${defense}\t${special}\t${speed}\t6\t6\t6\t6\t${attack}\t${defense}\t${special}\t${speed}\t6\t6\t1\t${typeOne}\t${typeTwo}\t${moveOne}\t${moveTwo}\t${moveThree}\t${moveFour}\t${moveOnePP}\t${moveTwoPP}\t${moveThreePP}\t${moveFourPP}\t${moveOnePPMax}\t${moveTwoPPMax}\t${moveThreePPMax}\t${moveFourPPMax}\t${majorAilment}\t${confusion}\t0\t0\t0\t0\t1\t0\t${lightScreen}\t${reflectValue}\t${sleepCounter}" >> "${battle_filetmp_path}/${attackingPokemon}.pokemon"


# This is when the pokemon flies down and inflicts damage. semiInvulnerability also needs to be switched off here too.
elif [ $counterVariableArgument -eq 1 ]; then

	echo "This is when the Pokemon comes down for an attack"
	echo "This is when the Pokemon comes down for an attack"
	echo "This is when the Pokemon comes down for an attack"
	echo "This is when the Pokemon comes down for an attack"
	echo "This is when the Pokemon comes down for an attack"


	read_attribute_battleFile "${battle_filetmp_path}/${attackingPokemon}.pokemon"
	> "${battle_filetmp_path}/${attackingPokemon}.pokemon"

	# Set semiInvulnerable = 0 - turn semi invulnerability off
	echo -e "${pokemonID}\t${pokemonUniqueID}\t${pokemonName}\t${level}\t${HP}\t${currentHP}\t${attack}\t${defense}\t${special}\t${speed}\t6\t6\t6\t6\t${attack}\t${defense}\t${special}\t${speed}\t6\t6\t1\t${typeOne}\t${typeTwo}\t${moveOne}\t${moveTwo}\t${moveThree}\t${moveFour}\t${moveOnePP}\t${moveTwoPP}\t${moveThreePP}\t${moveFourPP}\t${moveOnePPMax}\t${moveTwoPPMax}\t${moveThreePPMax}\t${moveFourPPMax}\t${majorAilment}\t${confusion}\t0\t0\t0\t0\t0\t0\t${lightScreen}\t${reflectValue}\t${sleepCounter}" >> "${battle_filetmp_path}/${attackingPokemon}.pokemon"

	attackerSpeciesID="$pokemonID"
	accuracy_check "$attackingPokemon" "$defendingPokemon" "$attackBeingUsed"

	if [ "$doesTheMoveHit" == "yes"  ]; then
    	calculate_crit_bonus "$attackerSpeciesID" "$attackingPokemon" 1
    	deal_damage "$attackingPokemon" "$defendingPokemon" "$attackBeingUsed" "$criticalModifier"
	elif [ "$doesTheMoveHit" == "no" ]; then
    	#NOTE Here temporarily for testing
    	echo "The attack missed! Write a function to call for this."
	fi
fi


# Calling growl, an example:
# $ bash 45.sh $AttackingPokemon $DefendingPokemon
# $ bash 45.sh PCPokemon NPCPokemon 
