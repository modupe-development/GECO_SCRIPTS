#!/usr/bin/perl
use strict;
open(OUT,">", $ARGV[3]);
$/= ">";
my %SEQ='';
open(IN,"<",$ARGV[0]);
while (<IN>){
	my @pieces = split /\n/;
	my $header = $pieces[0];
	my $seq = ''; my $qua = '';
	foreach my $num (1.. $#pieces){
		$seq .= $pieces[$num];
	}
	$SEQ{$header}=$seq;
}
$/="\n";
my $ref= (split("\:",$ARGV[1]))[0];
if (exists $SEQ{$ref}) {
	my @position=split("\-",((split("\:",$ARGV[1]))[1]),2);
	#$header = substr($filecontent[0],1,-1);
	my $count = $position[1]-$position[0]+1;
	my $seq = substr($SEQ{$ref},$position[0]-1,$count);
	if($ARGV[2] =~ /REV/){
		$seq=reverse($seq);
		$seq =~ tr/ACGTacgt/TGCAtgca/;
	}
	print OUT $seq."\n";
}

