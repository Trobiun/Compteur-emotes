#!/bin/bash
dir_logs="/var/lib/znc/users/trobiun/networks/twitch/moddata/log/#mygowd"			#le répertoire des fichiers de log
emotes_file="listEmotes.txt"									#le fichier contenant les emotes à compter
days=$(ls -lq "$dir_logs" | wc -l)
all_lines=$(grep -r "\*\*\*" "$dir_logs" | wc -l)
emotes_greped=$(grep -o -h -w -i -r -f "$emotes_file" "$dir_logs")				#récupère chaque utilisation de toutes les emotes
total_words=$(echo "$emotes_greped" | wc -l)							#compte le nombre total d'emotes utilisées
count_words=$(echo "$emotes_greped" | sort -f | uniq -c -i | sed -e 's/^[[:space:]]*//')	#compte le nombre d'utilisation pour toutes les emotes
total_lines=$(grep -w -i -r -f "$emotes_file" "$dir_logs" | wc -l)				#compte le nombre total de lignes contenant une emote
sort=false
emotes_while=$(cat "$emotes_file")								#définit les emotes qui seront parcourues par les emotes dans le fichier qui liste les emotes
if [ "$sort" = true ]
then
	sorted=$(echo "$emotes_greped" | sort -f | uniq -c -i | sort -n | awk '{ print $2 " : " $1 }' ) #trie les emotes par utilisation et les place au début de la ligne
	emotes_while=$(echo "$sorted" | cut -d ":" -f 1)					#définit le emotes qui seront parcourues par les emotes triées par utilisation
	sort_message="nombre d'utilisation"
else
	sort_message="ordre alphabétique"
fi
i=1
while read -r emote;										#parcourt le fichier emotes_file
do
	emotes[$i]="$emote"
	words[$i]=$(grep -i -w "$emote" <<< "$count_words" | cut -d " " -f 1)			#récupère le nombre d'utilisation (en mots) de l'emote actuelle
	count_lines[$i]=$(grep -w -i -r "$emote" "$dir_logs" | wc -l)				#compte le nombre de lignes dans lesquelles l'emote apparaît
	emotes_per_total[$i]=$(bc -l <<< "scale=7; (${words[$i]} / ${total_words}) * 100")	#calcule le poucentage d'utilisation (en mots) de l'emote
	words_per_line[$i]=$(bc -l <<< "scale=7; ${words[$i]} / ${count_lines[$i]}")		#calcule le nombre d'emote utilisée par ligne
	((i++))
done <<< "${emotes_while}"
