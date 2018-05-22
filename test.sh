#!/bin/bash
DIR_LOGS="/var/lib/znc/users/trobiun/networks/twitch/moddata/log/#mygowd"			#le répertoire des fichiers de log
EMOTES_FILE="listEmotes.txt"									#le fichier contenant les emotes à compter
EMOTES_GREPED=$(grep -o -h -w -i -r -f "$EMOTES_FILE" "$DIR_LOGS")				#récupère chaque utilisation de toutes les emotes
TOTAL_WORDS=$(echo "$EMOTES_GREPED" | wc -l)							#compte le nombre total d'emotes utilisées
COUNT_WORDS=$(echo "$EMOTES_GREPED" | sort -f | uniq -c -i | sed -e 's/^[[:space:]]*//')	#compte le nombre d'utilisation pour toutes les emotes
TOTAL_LINES=$(grep -w -i -r -f "$EMOTES_FILE" "$DIR_LOGS" | wc -l)				#compte le nombre total de lignes contenant une emote
while read -r EMOTE;										#parcourt le fichier EMOTES_FILE
do
	WORDS=$(grep -i -w "$EMOTE" <<< "$COUNT_WORDS" | cut -d " " -f 1)			#récupère le nombre d'utilisation (en mots) de l'emote actuelle
	COUNT_LINES=$(grep -w -i -r "$EMOTE" "$DIR_LOGS" | wc -l)				#compte le nombre de lignes dans lesquelles l'emote apparaît
	echo "$EMOTE :"										#affiche l'emote
	echo "	emotes		= $WORDS	/ $TOTAL_WORDS"					#affiche le nombre d'utilisation (en mots) de l'emote et le total
	EMOTES_PER_TOTAL=$(bc -l <<< "scale=7; ($WORDS / $TOTAL_WORDS) * 100")			#calcule le poucentage d'utilisation (en mots) de l'emote
	echo "	emote/total	= $EMOTES_PER_TOTAL %"						#affiche le pourcentage d'utilisation (en mots) de l'emote
	echo "	lignes		= $COUNT_LINES	/ $TOTAL_LINES"					#affiche le nombre de lignes contenant l'emote actuelle et le total de lignes contenant une emote
	WORDS_PER_LINE=$(bc -l <<< "scale=7; $WORDS / $COUNT_LINES")				#calcule le nombre d'emote utilisée par ligne
	echo "	emotes/lignes	= $WORDS_PER_LINE"						#affiche le nombre d'emote utilisée par ligne
done < "$EMOTES_FILE"
SORTED=$(echo "$EMOTES_GREPED" | sort -f | uniq -c -i | sort -n | sed -e 's/^[[:space:]]*//' | awk '{ print $2	"	: " $1 }' )
echo "Triées par nombre d'utilisation :"
echo "$SORTED"
