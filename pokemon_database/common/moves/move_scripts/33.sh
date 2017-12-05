#!/bin/bash

source "${HOME}/pokemon/gui/battles/battle_tools.sh"

attackingPokemon="$1"
defendingPokemon="$2"
attackBeingUsed=33
nameOfAttack="Tackle"
critRateMultiplierForMove=1

accuracy_crit_damage "$attackingPokemon" "$defendingPokemon" "$attackBeingUsed" "$nameOfAttack" "$critRateMultiplierForMove"

#NOTE The script that lowers PP of a move should occur and before outside of the move script
#NOTE The attack missing message should be part of the battle gui. The 'attack missed' message is just here for
# testing purposes.
