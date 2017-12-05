#!/bin/bash

art_files="${HOME}/text_dungeon/pokemon_database/art"
data_files="${HOME}/text_dungeon/menu_files/pokedex_files/pokedex_db/data"
pokemonID=$1
seen=$2
own=$3


# why even bother if you haven't seen it yet? smh
if [ "$seen" -eq 0 ]; then
	exit 0

# if we've seen but don't own
elif [ "$seen" -eq 1 -a "$own" -eq 0 ]; then
	clear
	cat ${art_files}/${pokemonID}.art
	cat ${data_files}/NOT_CAUGHT.data
	
	read -n1 input < /dev/tty
	clear
	exit 0;

# only other option is if we've seen AND own it
else
	clear
	cat ${art_files}/${pokemonID}.art
	cat ${data_files}/${pokemonID}1.data
	printf '							\e[5;32;40m▼\e[m\n'
	
	read -n1 input < /dev/tty

	clear
	cat ${art_files}/${pokemonID}.art
	cat ${data_files}/${pokemonID}2.data

	read -n1 input < /dev/tty

	clear
	exit 0

fi

