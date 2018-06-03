#!/bin/bash
set -o errexit
set -o nounset

#fonctions
mysort () {
	sortArgs="--ignore-case"
	if [ "${1}" = "numeric" ]
	then
		sortArgs="--numeric-sort"
	else
		sortArgs="--dictionary-order ${sortArgs}"
	fi
	if [ "$order" = "dsc" ]
	then
		sortArgs="--reverse ${sortArgs}"
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
EMOTES_FILE="emotes.list"									#le fichier contenant les emotes à compter
#arguments provenant de l'appel du script php
sortby="${@:3:1}"
order="${@:4:1}"

count_days=$(find "${DIR_LOGS}" -type f | wc --lines)
lines_conv=$(grep --recursive --invert-match "\*\*\*" "${DIR_LOGS}")
count_lines_conv=$(wc --lines <<< "${lines_conv}")

lines_with_emotes=$(grep --no-filename --word-regexp --ignore-case --recursive --file="${EMOTES_FILE}" "${DIR_LOGS}")
count_lines_with_emotes=$(wc --lines <<< "${lines_with_emotes}")
percent_lines_with_emotes=$(bc --mathlib <<< "scale=7; (${count_lines_with_emotes} * 100) / ${count_lines_conv}")

emotes_greped=$(grep --only-matching --no-filename --word-regexp --ignore-case --file="${EMOTES_FILE}" <<< "${lines_with_emotes}")

count_total_emotes=$(wc --lines <<< "${emotes_greped}")

use_per_emote=$(echo "${emotes_greped}" | sort --ignore-case | uniq --count --ignore-case | sed --expression='s/^[[:space:]]*//')	#compte le nombre d'utilisation pour toutes les emotes
average_emotes_per_line=$(bc --mathlib <<< "scale=7; ${count_total_emotes} / ${count_lines_with_emotes}")

emotes_while=$(mysort "${sortby}" "${order}" "${use_per_emote[@]}")

#emotes_lines1=$(wc --lines <<< "${emotes_greped}")				#compte le nombre total de lignes contenant une emote
emotes_lines=$(grep --word-regexp --ignore-case --recursive --file="${EMOTES_FILE}" "${DIR_LOGS}" | wc --lines)				#compte le nombre total de lignes contenant une emote
#plus compliqué et à peine plus lent
#emotes_lines3=$(grep --word-regexp --no-filename --ignore-case --recursive --file="${EMOTES_FILE}" "${DIR_LOGS}" --count)				#compte le nombre total de lignes contenant une emote
#emotes_lines_plus=$(tr '\n' '+' <<< "${emotes_lines3}")
#emotes_lines_sum=$(time bc --mathlib <<< "${emotes_lines_plus}0")  #$(sed --expression='s/[[:space:]]/\+/g'  <<< \"${emotes_lines3}\"))
if [ "${order}" = "asc" ]
then
	orderMessage="croissant"
else
	orderMessage="décroissant"
fi
if [ "${sortby}" = "numeric" ]
then
	sort_message="utilisation ${orderMessage}"
else
	sort_message="ordre alphabétique ${orderMessage}"
fi
i=1
while read -r emote;										#parcourt le fichier emotes_file
do
	emotes[$i]=$(cut --delimiter=":" --fields=1 <<< "${emote}")
	words[$i]=$(grep --ignore-case --word-regexp "${emotes[$i]}" <<< "${use_per_emote}" | cut --delimiter=" " --fields=1)			#récupère le nombre d'utilisation (en mots) de l'emote actuelle
	count_lines[$i]=$(grep --word-regexp --ignore-case --recursive "${emotes[$i]}" "${DIR_LOGS}" | wc --lines)				#compte le nombre de lignes dans lesquelles l'emote apparaît
	emotes_per_total[$i]=$(bc --mathlib <<< "scale=7; (${words[$i]} * 100) / ${count_total_emotes}")	#calcule le poucentage d'utilisation (en mots) de l'emote
	words_per_line[$i]=$(bc --mathlib <<< "scale=7; ${words[$i]} / ${count_lines[$i]}")		#calcule le nombre d'emote utilisée par ligne
	((i++))
done <<< "${emotes_while}"
