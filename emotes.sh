#!/bin/bash
set -o errexit
set -o nounset

dir_logs="/var/lib/znc/users/trobiun/networks/twitch/moddata/log/#mygowd"			#le répertoire des fichiers de log
emotes_file="emotes.list"									#le fichier contenant les emotes à compter

days=$(find "$dir_logs" -type f | wc --lines)
all_lines=$(grep --recursive --invert-match "\*\*\*" "$dir_logs" | wc --lines)
datetime=$(date)
echo "Statistiques faites sur $days jours et $all_lines lignes le ${datetime} :"

emotes_greped=$(grep --only-matching --no-filename --word-regexp --ignore-case --recursive --file="$emotes_file" "$dir_logs")				#récupère chaque utilisation de toutes les emotes
total_words=$(echo "${emotes_greped}" | wc --lines)							#compte le nombre total d'emotes utilisées
count_words=$(echo "${emotes_greped}" | sort --ignore-case | uniq --count --ignore-case | sed --expression='s/^[[:space:]]*//')	#compte le nombre d'utilisation pour toutes les emotes
total_lines=$(grep --word-regexp --ignore-case --recursive --file="$emotes_file" "$dir_logs" | wc --lines)				#compte le nombre total de lignes contenant une emote
sort=true
emotes_while=$(cat "$emotes_file")								#définit les emotes qui seront parcourues par les emotes dans le fichier qui liste les emotes
if [ "$sort" = true ]
then
	sorted=$(echo "${emotes_greped}" | sort --ignore-case | uniq --count --ignore-case | sort --numeric-sort | awk '{ print $2 " : " $1 }' ) #trie les emotes par utilisation et les place au début de la ligne
	emotes_while=$(echo "${sorted}" | cut --delimiter=":" --fields=1)					#définit le emotes qui seront parcourues par les emotes triées par utilisation
	echo "Triées par utlisation croissante"
else
	echo "Triées par ordre alphabétique"
fi
while read -r emote;										#parcourt le fichier EMOTES_FILE
do
	words=$(echo "${count_words}" | grep --ignore-case --word-regexp "$emote" | cut --delimiter=" " --fields=1)			#récupère le nombre d'utilisation (en mots) de l'emote actuelle
	count_lines=$(grep --word-regexp --ignore-case --recursive "$emote" "$dir_logs" | wc --lines)				#compte le nombre de lignes dans lesquelles l'emote apparaît
	echo "$emote :"										#affiche l'emote
	echo "	emotes		= $words	/ $total_words"					#affiche le nombre d'utilisation (en mots) de l'emote et le total
	emotes_per_total=$(echo "scale=7; (${words} / ${total_words}) * 100" | bc --mathlib)			#calcule le poucentage d'utilisation (en mots) de l'emote
	echo "	emote/total	= $emotes_per_total %"						#affiche le pourcentage d'utilisation (en mots) de l'emote
	echo "	lignes		= $count_lines	/ $total_lines"					#affiche le nombre de lignes contenant l'emote actuelle et le total de lignes contenant une emote
	words_per_line=$(echo "scale=7; (${words} / ${count_lines})" | bc --mathlib)				#calcule le nombre d'emote utilisée par ligne
	echo "	emotes/ligne	= $words_per_line"						#affiche le nombre d'emote utilisée par ligne
done <<< "${emotes_while}"
