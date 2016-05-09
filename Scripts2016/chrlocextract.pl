#!/usr/bin/perl
open(IN,"<",$ARGV[0]);
open(OUT,">", $ARGV[3]);
@filecontent = <IN>;
close (IN);
@position=split("\-",((split("\:",$ARGV[1]))[1]),2);
#$header = substr($filecontent[0],1,-1);
$seq = substr($filecontent[1],$position[0]-1,-1);
if($ARGV[2] =~ /REV/){
	$seq=reverse($seq);
	$seq =~ tr/ACGTacgt/TGCAtgca/;
}
print OUT $seq."\n";



	
