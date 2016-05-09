#!/usr/bin/perl

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
use strict;
#Fix the header names of each chromosome in the mouse genome.
#The output is Outmouse.txt

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# THE FILE PATH
my $filepath = $ARGV[0];
#my $output = $ARGV[1];

# HASH TABLE
my %SEQ;

#OPENING FILE
open (TABLE, "<$filepath") or die "Can't open file $filepath\n";
$/ = ">"; 
my @fastaFILE = <TABLE>;
close(TABLE);

#open (OUT, ">$output") or die "Can't open file $output\n";

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
shift (@fastaFILE);
my $gencount = 0;
foreach my $entry (@fastaFILE){
	my @pieces = split(/\n/, $entry);
	my $header = $pieces[0];   #print $header;#because the header name wont be unique
	$gencount++;
	my $seq = $pieces[1];
	foreach my $i (2..$#pieces-1){
    	$seq = $seq.$pieces[$i];
	}
	$SEQ{$header} = $seq;
}

$/ = "\n";  #returning back to the default
my $sequence;
my $lengthall = 0;
my $output = 1; my $filename = "OutMouse";
open (OUT, ">".$filename.".txt");
foreach my $dent (sort keys %SEQ){
	if ($dent =~ /\|/){
		my @name = split('\|', $dent);
		$output++;
		print OUT ">".$name[3]."\n".$SEQ{$dent}."\n";
	}
	else {
		print OUT ">".$dent."\n".$SEQ{$dent}."\n";
	}
	$sequence = $SEQ{$dent}; 
	print "$dent\t".length($sequence)."\n";
	$lengthall = $lengthall + length($sequence);
	#print "$dent\t";
	#printf "%-8s %s\t", $dent;
}
close (OUT);
print "\nlength of all sequences\t$lengthall\nnumber of genes\t$gencount\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
exit;

