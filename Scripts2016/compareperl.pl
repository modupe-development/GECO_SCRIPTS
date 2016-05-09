#!/usr/bin/perl
open (IN1, "<$ARGV[0]");
while (<IN1>){
	chomp;
	#$oldword = substr($_,1,-1);
	#$word = uc($oldword);
	@words = split("\t",$_,5);
	$word = $words[1];
	$worded = "$word|$words[2]|$words[3]|$words[4]";
	if (exists $ONE{$word}) {
		$ONE{$word} = $ONE{$word}+1;
		$TWO{$word} = "$TWO{$word},$worded";
	}
	else {
		$ONE{$word} = 1;
		$TWO{$word} = "$worded";
	}
}
foreach my $real (keys %ONE){
	if ($ONE{$real} > 1){
		print $real."\t".$ONE{$real}."\t".$TWO{$real}."\n";
	}
}
