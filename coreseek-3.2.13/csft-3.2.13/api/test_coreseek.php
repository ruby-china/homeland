<?php
require ( "sphinxapi.php" );

$cl = new SphinxClient ();
$cl->SetServer ( '127.0.0.1', 9312);
$cl->SetConnectTimeout ( 1 );
$cl->SetArrayResult ( true );
//$cl->SetWeights ( array ( 100, 1 ) );
$cl->SetMatchMode ( SPH_MATCH_EXTENDED2 );
$cl->SetRankingMode ( SPH_RANK_WORDCOUNT );

//$cl->SetSortMode ( SPH_SORT_EXTENDED, '@weight DESC' );
//$cl->SetSortMode ( SPH_SORT_EXPR, $sortexpr );

//$cl->SetFieldWeights(array('title'=>10,'content'=>1));
$res = $cl->Query ( 'sphinxse', "*" );
print_r($res['matches']);