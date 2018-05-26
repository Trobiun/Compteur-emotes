#!/bin/bash
dir_logs="/var/lib/znc/users/trobiun/networks/twitch/moddata/log/#mygowd"			#le répertoire des fichiers de log
emotes_file="listEmotes.txt"									#le fichier contenant les emotes à compter
days=$(find "$dir_logs" | wc -l)
all_lines=$(grep -r "\*\*\*" "$dir_logs" | wc -l)
echo "Statistiques faites sur $days jours et $all_lines lignes :"
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
	echo "Triées par nombre d'utlisation"
else
	echo "Triées par ordre alphabétique"
fi
while read -r emote;										#parcourt le fichier EMOTES_FILE
do
	words=$(grep -i -w "$emote" <<< "$count_words" | cut -d " " -f 1)			#récupère le nombre d'utilisation (en mots) de l'emote actuelle
	count_lines=$(grep -w -i -r "$emote" "$dir_logs" | wc -l)				#compte le nombre de lignes dans lesquelles l'emote apparaît
	echo "$emote :"										#affiche l'emote
	echo "	emotes		= $words	/ $total_words"					#affiche le nombre d'utilisation (en mots) de l'emote et le total
	emotes_per_total=$(bc -l <<< "scale=7; ($words / $total_words) * 100")			#calcule le poucentage d'utilisation (en mots) de l'emote
	echo "	emote/total	= $emotes_per_total %"						#affiche le pourcentage d'utilisation (en mots) de l'emote
	echo "	lignes		= $count_lines	/ $total_lines"					#affiche le nombre de lignes contenant l'emote actuelle et le total de lignes contenant une emote
	words_per_line=$(bc -l <<< "scale=7; $words / $count_lines")				#calcule le nombre d'emote utilisée par ligne
	echo "	emotes/ligne	= $words_per_line"						#affiche le nombre d'emote utilisée par ligne
done <<< "$emotes_while"
