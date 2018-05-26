<?php


exec("./render.sh template.html emotesTemplate.sh  2>&1",$array);
foreach ($array as $key =>$value) {
	print_r($value);
}

