<?php

$sort = filter_input(INPUT_GET, 'sort', FILTER_SANITIZZE_FULL_SPECIAL_CHARSS);

exec("./render.sh template.html emotesTemplate.sh $sort 2>&1",$array);
foreach ($array as $key =>$value) {
	print_r($value);
}

