#!/bin/bash
function format_file_as_JSON_string() {
	sed -e 's/\\/\\\\/g' \
	-e 's/$/\\n/g' \
	-e 's/"/\\"/g' \
	-e 's/\t/\\t/g' \
	| tr -d "\n"
}
cd "/home/robin/mygowd/CompteurEmotes"
USER="-uTrobiun:hsWD4JDaQ8Vc"
#DESCRIPTION="\"description\": \"$(echo 'Compte des emotes' | awk '{gsub(/"/, "\\\"")} 1')\", "
PUBLIC="true"
FILENAME="\"Compteur emotes\""
CONTENT="\"$(./emotes.sh | format_file_as_JSON_string)\""
echo "{${DESCRIPTION}\"public\": ${PUBLIC}, \"files\": {${FILENAME}: {\"content\": ${CONTENT}}}}" | curl --silent "${USER}" -X PATCH -H 'Content-Type: application/json' -d @- https://api.github.com/gists/f3ef22130c2a0d64efb0318091f77662
