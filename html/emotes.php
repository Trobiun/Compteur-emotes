<?php

$sortby = escapeshellarg(filter_input(INPUT_GET,'sortby',FILTER_SANITIZE_FULL_SPECIAL_CHARS));
if ($sortby == null) {
	$sort = "false";
}

$order = escapeshellarg(filter_input(INPUT_GET,'order',FILTER_SANITIZE_FULL_SPECIAL_CHARS));
if ($order == null) {
	$order = "asc";
}
exec("./render.sh template.html emotes_template.sh $sortby $order 2>&1",$array);
foreach ($array as $key =>$value) {
	print_r($value);
}

