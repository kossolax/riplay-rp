<?php
$error = array();

// Liste des erreurs 3xx
//	Redirection
$error[300]['titre'] =  'Multiple Choices';
$error[300]['sub'] =    'L\'URI demandée se rapporte à plusieurs ressources.';
$error[301]['titre'] =  'Moved Permanently';
$error[301]['sub'] =    'Document déplacé de façon permanente.';
$error[302]['titre'] =  'Moved Temporarily';
$error[302]['sub'] =    'Document déplacé de façon temporaire.';
$error[303]['titre'] =  'See Other';
$error[303]['sub'] =    'La réponse à cette requête est ailleurs.';
$error[304]['titre'] =  'Not Modified';
$error[304]['sub'] =    'Document non modifié depuis la dernière requête.';
$error[305]['titre'] =  'Use Proxy';
$error[305]['sub'] =    'La requête doit être ré-adressée au proxy.';
$error[307]['titre'] =  'Temporary Redirect';
$error[307]['sub'] =    'La requête doit être redirigée temporairement vers l\'URI spécifiée.';
$error[310]['titre'] =  'Too many Redirects';
$error[310]['sub'] =    'La requête doit être redirigée de trop nombreuses fois, ou est victime d\'une boucle de redirection.';

// Liste des erreurs 4xx
//	Erreur du "client"
$error[400]['titre'] =	'Bad Request';
$error[400]['sub'] =	'La syntaxe de la requête est erronée.';
$error[401]['titre'] =	'Unauthorized';
$error[401]['sub'] =    'Une authentification est nécessaire pour accéder à la ressource.';
$error[402]['titre'] =  'Payment Required';
$error[402]['sub'] =    'Paiement requis pour accéder à la ressource.';
$error[403]['titre'] =  'Forbidden';
$error[403]['sub'] =    'L\'authentification est refusée.';
$error[404]['titre'] =  'Not Found';
$error[404]['sub'] =    'La page que vous avez demandée n\'existe pas, ou plus.';
$error[405]['titre'] =  'Method Not Allowed';
$error[405]['sub'] =    'Méthode de requête non autorisée.';
$error[406]['titre'] =  'Not Acceptable';
$error[406]['sub'] =    'Toutes les réponses possibles seront refusées.';
$error[407]['titre'] =  'Proxy Authentication Required';
$error[407]['sub'] =    'Accès à la ressource autorisé par identification avec le proxy.';
$error[408]['titre'] =  'Request Time-out';
$error[408]['sub'] =    'Temps d\'attente d\'une réponse du serveur écoulé.';
$error[409]['titre'] =  'Conflict';
$error[409]['sub'] =    'La requête ne peut être traitée à l\'état actuel.';
$error[410]['titre'] =  'Gone';
$error[410]['sub'] =    'La ressource est indisponible et aucune adresse de redirection n\'est connue.';
$error[411]['titre'] =  'Length Required';
$error[411]['sub'] =    'La longueur de la requête n\'a pas été précisée.';
$error[412]['titre'] =  'Precondition Failed';
$error[412]['sub'] =    'Préconditions envoyées par la requête non-vérifiées.';
$error[413]['titre'] =  'Request Entity Too Large';
$error[413]['sub'] =    'Traitement abandonné dÃ» à une requête trop importante.';
$error[414]['titre'] =  'Request-URI Too Long';
$error[414]['sub'] =    'URI trop longue.';
$error[415]['titre'] =  'Unsupported Media Type';
$error[415]['sub'] =    'Format de requête non-supportée pour une méthode et une ressource données.';
$error[416]['titre'] =  'Requested range unsatisfiable';
$error[416]['sub'] =    'Champs d\'en-tête de requête Â« range Â» incorrect.';
$error[417]['titre'] =  'Expectation failed';
$error[417]['sub'] =    'Comportement attendu et défini dans l\'en-tête de la requête insatisfaisable';
$error[418]['titre'] =  'I\'m a teapot';
$error[418]['sub'] =    'Je suis une théière.';
// Liste des erreurs 5xx
//	Erreur du serveur
$error[500]['titre'] =  'Internal Server Error';
$error[500]['sub'] =    'Erreur interne du serveur.';
$error[501]['titre'] =  'Not Implemented';
$error[501]['sub'] =    'Fonctionnalité réclamée non supportée par le serveur.';
$error[502]['titre'] =  'Bad Gateway ou Proxy Error';
$error[502]['sub'] =    'Mauvaise réponse envoyée à un serveur intermédiaire par un autre serveur.';
$error[503]['titre'] =  'Service Unavailable';
$error[503]['sub'] =    'Service temporairement indisponible ou en maintenance.';
$error[504]['titre'] =  'Gateway Time-out';
$error[504]['sub'] =    'Temps d\'attente d\'une réponse d\'un serveur à un serveur intermédiaire écoulé.';
$error[505]['titre'] =  'HTTP Version not supported';
$error[505]['sub'] =    'Version HTTP non gérée par le serveur.';
$error[507]['titre'] =  'Insufficient storage';
$error[507]['sub'] =    'Espace insuffisant pour modifier les propriétés ou construire la collection.';
$error[509]['titre'] =  'Bandwidth Limit Exceeded';
$error[509]['sub'] =    'Dépassement du quota fixé par le serveur.';

$error[542]['titre'] =  'Soon';
$error[542]['sub'] =    'Cette fonctionnalité arrive très bientôt.';

if( intval($_GET['erreur']) == 0 ) {
	$_GET['erreur'] = 404;
}

header("HTTP/1.0 ".$_GET['erreur']." ".$error[$_GET['erreur']]['titre']."");

$tpl = new raintpl();
$tpl->assign('error_num', intval($_GET['erreur']));
$tpl->assign('error_text', $error[$_GET['erreur']]);
$tpl->assign('back', $_GET['back']);
$tpl->assign('debug', unserialize(base64_decode(decode($_GET['str'], "lol"))) );

$tpl->assign("nick", preg_replace("/[^a-zA-Z0-9]+/", "", $user->data['username']));
draw($tpl->draw("page_fail", $return_string=true), "Erreur" );

?>
