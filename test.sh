#!/bin/bash
set -o errexit
set -o nounset

DIR_LOGS="/var/lib/znc/users/trobiun/networks/twitch/moddata/log/#mygowd"			#le répertoire des fichiers de log
EMOTES_FILE="emotes_list.txt"									#le fichier contenant les emotes à compter
LIST_USER_FILE="users_list.txt"									#le fichier pour whitelist et blacklist les  utilisateurs

users_array_to_file() {
	list_users="$@"
	echo "${list_users[@]}" | sed -e 's/[[:space:]]/\n/g' | sed -e 's/^/</g' | sed -e 's/$/>/g' >  "${LIST_USER_FILE}"
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
	list_greped=$(grep $grep_args <<< "${@:2}")
	echo "${list_greped}"
}

#grep en premier les utilisateurs puis calculer  les emotes_greped ?
#ou enlever le -o dans emotes_greped puis grep les utilisateurs puis
#regrep les emotes ?
#à tester la rapidité, la 1ère est peut-être mieux
declare -a blacklist_users=("trobiun" "nyanmaruchan" "xanagi" "lernardeau")
declare -a whitelist_users=()

all_lines=$(find "${DIR_LOGS}" -type f -exec cat  '{}' ';' | grep --invert-match "\*\*\*")
#echo "${all_lines}"
#blacklist_greped="${DIR_LOGS}"
#if [ "${blacklistUsers[0]}" ]
#then
	#for user in "${blacklistUsers[@]}"
	#do
	#	echo "${user}"
	#done
#	echo "${blacklistUsers[@]}" | sed -e 's/[[:space:]]/\n/g' | sed -e 's/^/</g' | sed -e 's/$/>/g' >  "blacklistUsers.txt"
	#grep -r <<< "${DIR_LOGS}" -f "blacklistUsers.txt"
#	blacklist_greped=$(grep -w --file="blacklistUsers.txt" --recursive "${DIR_LOGS}")
	#echo "${blacklist_greped}"
#fi
#exit;

days=$(find "${DIR_LOGS}" | wc -l)
count_all_lines=$(wc -l <<< "${all_lines}")
#echo "$count_all_lines"
#users_array_to_file "${blacklist_users[@]}"
#cat "${LIST_USER_FILE}"
test=$(filterlist "true" "${all_lines}")
#echo "${test}"
#exit;
#all_lines=$(grep -r "\*\*\*" "${DIR_LOGS}" | wc -l)
echo "Statistiques faites sur ${days} jours et ${count_all_lines} lignes :"
emotes_greped=$(grep -o -h -w -i  -f "${EMOTES_FILE}" <<< "${all_lines}")				#récupère chaque utilisation de toutes les emotes
#echo "$emotes_greped"
#exit;
total_words=$(echo "$emotes_greped" | wc -l)							#compte le nombre total d'emotes utilisées
count_words=$(echo "$emotes_greped" | sort -f | uniq -c -i | sed -e 's/^[[:space:]]*//')	#compte le nombre d'utilisation pour toutes les emotes
total_lines=$(grep -w -i -r -f "${EMOTES_FILE}" "${DIR_LOGS}" | wc -l)				#compte le nombre total de lignes contenant une emote
sort=false
emotes_while=$(cat "${EMOTES_FILE}")								#définit les emotes qui seront parcourues par les emotes dans le fichier qui liste les emotes
if [ "$sort" = true ]
then
	sorted=$(echo "$emotes_greped" | sort -f | uniq -c -i | sort -n | awk '{ print $2 " : " $1 }' ) #trie les emotes par utilisation et les place au début de la ligne
	emotes_while=$(echo "$sorted" | cut -d ":" -f 1)					#définit le emotes qui seront parcourues par les emotes triées par utilisation
	echo "Triées par nombre d'utlisation"
else
	echo "Triées par ordre alphabétique"
fi
while read -r emote;										#parcourt le fichier EMOTES_FILE
do
	words=$(grep -i -w "$emote" <<< "$count_words" | cut -d " " -f 1)			#récupère le nombre d'utilisation (en mots) de l'emote actuelle
	count_lines=$(grep -w -i -r "$emote" "${DIR_LOGS}" | wc -l)				#compte le nombre de lignes dans lesquelles l'emote apparaît
	echo "$emote :"										#affiche l'emote
	echo "	emotes		= $words	/ $total_words"					#affiche le nombre d'utilisation (en mots) de l'emote et le total
	emotes_per_total=$(bc -l <<< "scale=7; ($words / $total_words) * 100")			#calcule le poucentage d'utilisation (en mots) de l'emote
	echo "	emote/total	= $emotes_per_total %"						#affiche le pourcentage d'utilisation (en mots) de l'emote
	echo "	lignes		= $count_lines	/ $total_lines"					#affiche le nombre de lignes contenant l'emote actuelle et le total de lignes contenant une emote
	words_per_line=$(bc -l <<< "scale=7; $words / $count_lines")				#calcule le nombre d'emote utilisée par ligne
	echo "	emotes/ligne	= $words_per_line"						#affiche le nombre d'emote utilisée par ligne
done <<< "$emotes_while"
rm "${LIST_USER_FILE}"
