#!/bin/bash
set -o errexit
set -o nounset

DIR_LOGS="/var/lib/znc/users/trobiun/networks/twitch/moddata/log/#mygowd"			#le répertoire des fichiers de log
EMOTES_FILE="emotes_list.txt"									#le fichier contenant les emotes à compter
LIST_USER_FILE="users_list.txt"									#le fichier pour whitelist et blacklist les  utilisateurs

users_array_to_file() {
	echo "$@" | sed --expression='s/[[:space:]]/\n/g' | sed --expression='s/^/</g' | sed --expression='s/$/>/g' > "${LIST_USER_FILE}"
}

filterlist() {
	whitelist="$1"
	#list_lines="${@:2}"
	grep_args="--word-regexp --file=${LIST_USER_FILE}"
	if [ "${whitelist}" = "false" ]
	then
		grep_args="--invert-match ${grep_args}"
	fi
	#exit;
	list_greped=$(echo "${@:2}" | grep $grep_args)
	echo "${list_greped}"
}

#grep en premier les utilisateurs puis calculer  les emotes_greped ?
#ou enlever le -o dans emotes_greped puis grep les utilisateurs puis
#regrep les emotes ?
#à tester la rapidité, la 1ère est peut-être mieux
declare -a blacklist_users=("trobiun" "nyanmaruchan" "xanagi" "lernardeau")
declare -a whitelist_users=()
lines=$(find "${DIR_LOGS}" -type f -exec cat  '{}' ';' | grep --invert-match "\*\*\*")

days=$(find "${DIR_LOGS}" -type f | wc --lines)
count_all_lines=$(echo "${lines}" | wc --lines)
if [ "${blakclist_users[@]}" ]
then
	user_array_to_file "${blacklist_users[@]}"
	lines=$(filterlist "false" "${lines}")
fi
if [ "${whitelist_users[@]}" ]
then
	users_array_to_file "${whitelist_users[@]}"
	lines=$(filterlist "true" "${lines}")
fi
echo "Statistiques faites sur ${days} jours et ${count_all_lines} lignes :"
emotes_greped=$(echo "${lines}" | grep --only-matching --no-filename --word-regexp --ignore-case  --file="${EMOTES_FILE}")				#récupère chaque utilisation de toutes les emotes
total_words=$(echo "$emotes_greped" | wc --lines)							#compte le nombre total d'emotes utilisées
count_words=$(echo "$emotes_greped" | sort -f | uniq --count --ignore-case | sed --expression='s/^[[:space:]]*//')	#compte le nombre d'utilisation pour toutes les emotes
total_lines=$(grep --word-regexp --ignore-case --recursive --file="${EMOTES_FILE}" "${DIR_LOGS}" | wc --lines)				#compte le nombre total de lignes contenant une emote
sort=false
emotes_while=$(cat "${EMOTES_FILE}")								#définit les emotes qui seront parcourues par les emotes dans le fichier qui liste les emotes
if [ "$sort" = true ]
then
	sorted=$(echo "$emotes_greped" | sort -f | uniq --count --ignore-case | sort --numeric-sort | awk '{ print $2 " : " $1 }' ) #trie les emotes par utilisation et les place au début de la ligne
	emotes_while=$(echo "$sorted" | cut --delimiter=":" --fields=1)					#définit le emotes qui seront parcourues par les emotes triées par utilisation
	echo "Triées par nombre d'utlisation"
else
	echo "Triées par ordre alphabétique"
fi
while read -r emote;										#parcourt le fichier EMOTES_FILE
do
	words=$(echo "${count_words}" | grep --ignore-case --word-regexp "$emote" | cut --delimiter=" " --fields=1)			#récupère le nombre d'utilisation (en mots) de l'emote actuelle
	count_lines=$(grep --word-regexp --ignore-case --recursive "$emote" "${DIR_LOGS}" | wc --lines)				#compte le nombre de lignes dans lesquelles l'emote apparaît
	echo "$emote :"										#affiche l'emote
	echo "	emotes		= $words	/ $total_words"					#affiche le nombre d'utilisation (en mots) de l'emote et le total
	emotes_per_total=$(echo "scale=7; (${words} / ${total_words}) * 100" | bc --mathlib)			#calcule le poucentage d'utilisation (en mots) de l'emote
	echo "	emote/total	= $emotes_per_total %"						#affiche le pourcentage d'utilisation (en mots) de l'emote
	echo "	lignes		= $count_lines	/ $total_lines"					#affiche le nombre de lignes contenant l'emote actuelle et le total de lignes contenant une emote
	words_per_line=$(echo "scale=7; ${words} / ${count_lines}" | bc --mathlib)				#calcule le nombre d'emote utilisée par ligne
	echo "	emotes/ligne	= $words_per_line"						#affiche le nombre d'emote utilisée par ligne
done <<< "$emotes_while"
if [ -f "${LIST_USER_FILE}" ]
then
	rm -f "${LIST_USER_FILE}"
fi
