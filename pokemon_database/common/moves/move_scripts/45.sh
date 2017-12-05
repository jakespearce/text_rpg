#!/bin/bash
# Growl lowers the targets attack by one stage

source "${HOME}/pokemon/gui/battles/battle_tools.sh"

attackingPokemon="$1"
defendingPokemon="$2"
attackBeingUsed=45
nameOfAttack="Growl"
attributeToModify="attack"
modifierValue=-1

# Here we need to verify that changing the attribute by a given stage doesn't make it greater than 12 or less than 0
# If it would raise it above 12 or decrease to below 0 then the attack fails.
statStageModCheck "$defendingPokemon" "$attributeToModify" "$modifierValue"

if [ "$fail" == "true" ]; then
	# Temporary until we sort out more UI stuff
	echo "Growl failed"
else
	modifyAttributeByStage "$defendingPokemon" "$attributeToModify" "$modifierValue"
fi

# Calling growl, an example:
# $ bash 45.sh $AttackingPokemon $DefendingPokemon
# $ bash 45.sh PCPokemon NPCPokemon 
