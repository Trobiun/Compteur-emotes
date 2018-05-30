#!/bin/bash
set -o errexit
set -o nounset

#fonctions
mysort () {
	sortArgs="--ignore-case"
	if [ "${1}" = "numeric" ]
	then
		sortArgs="--numeric-sort"
		sort_message="utilisation"
	else
		sortArgs="--dictionary-order ${sortArgs}"
		sort_message="alphabétique"
	fi
	if [ "$order" = "dsc" ]
	then
		sortArgs="--reverse ${sortArgs}"
		orderMessage="descendant"
	else
		orderMessage="ascendant"
	fi
	count_words="${@:3}"
	if [ "${1}" = "numeric" ]
	then
		emotes_while=$(echo "${count_words}" | sort ${sortArgs} | awk '{ print $2 ":" $1 }')
	else
		emotes_while=$(echo "${count_words}" | awk '{ print $2 ":" $1 }' | sort ${sortArgs})
	fi
	echo "${emotes_while}"
}

#paramètres
DIR_LOGS="/var/lib/znc/users/trobiun/networks/twitch/moddata/log/#mygowd"			#le répertoire des fichiers de log
EMOTES_FILE="emotes_unsorted.list"									#le fichier contenant les emotes à compter
#arguments provenant de l'appel du script php
sortby="${@:3:1}"
order="${@:4:1}"

days=$(find "${DIR_LOGS}" -type f | wc --lines)
all_lines=$(grep --recursive --invert-match "\*\*\*" "${DIR_LOGS}" | wc --lines)
emotes_greped=$(grep --only-matching --no-filename --word-regexp --ignore-case --recursive --file="${EMOTES_FILE}" "${DIR_LOGS}")				#récupère chaque utilisation de toutes les emotes
total_words=$(echo "$emotes_greped" | wc --lines)							#compte le nombre total d'emotes utilisées
count_words=$(echo "$emotes_greped" | sort --ignore-case | uniq --count --ignore-case | sed --expression='s/^[[:space:]]*//')	#compte le nombre d'utilisation pour toutes les emotes
emotes_while=$(mysort "$sortby" "$order" "${count_words[@]}")
total_lines=$(grep --word-regexp --ignore-case --recursive --file="${EMOTES_FILE}" "${DIR_LOGS}" | wc --lines)				#compte le nombre total de lignes contenant une emote
if [ "${order}" = "asc" ]
then
	orderMessage="croissant"
else
	orderMessage="décroissant"
fi
if [ "${sortby}" != "numeric" ]
then
	sort_message="ordre alphabétique ${orderMessage}"
else
	sort_message="ordre numérique ${orderMessage}"
fi
i=1
while read -r emote;										#parcourt le fichier emotes_file
do
	emotes[$i]=$(cut --delimiter=":" --fields=1 <<< "${emote}")
	words[$i]=$(grep --ignore-case --word-regexp "${emotes[$i]}" <<< "${count_words}" | cut --delimiter=" " --fields=1)			#récupère le nombre d'utilisation (en mots) de l'emote actuelle
	count_lines[$i]=$(grep --word-regexp --ignore-case --recursive "${emotes[$i]}" "${DIR_LOGS}" | wc --lines)				#compte le nombre de lignes dans lesquelles l'emote apparaît
	emotes_per_total[$i]=$(bc --mathlib <<< "scale=7; (${words[$i]} / ${total_words}) * 100")	#calcule le poucentage d'utilisation (en mots) de l'emote
	words_per_line[$i]=$(bc --mathlib <<< "scale=7; ${words[$i]} / ${count_lines[$i]}")		#calcule le nombre d'emote utilisée par ligne
	((i++))
done <<< "${emotes_while}"
