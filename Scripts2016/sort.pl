#!/usr/bin/perl

open(IN1,"<", $ARGV[0]);
open (IN2,"<", $ARGV[1]);
open (OUT, ">" , $ARGV[2]);
%SMALL = ''; %BIG='';
while (<IN1>){
	chomp;
	my $col =(split("\t", $_))[0];
	$SMALL{$col} = $_;
} close IN1;
while (<IN2>){
	chomp;
	my $col2 = (split("\t",$_))[0];
	$BIG{$col2} = $_;
} close IN2;

for ($I=0;$I<1545;$I++){
	if (exists $BIG{$I}){
		if (exists $SMALL{$I}){
			print OUT "$SMALL{$I}\n";
		}
		else {
			print OUT "$BIG{$I}\n";
		}
	}
}
close OUT;
