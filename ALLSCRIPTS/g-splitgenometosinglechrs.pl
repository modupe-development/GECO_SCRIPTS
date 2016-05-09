#!/usr/bin/perl

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
use strict;

#Split a reference genome to their individual chromosomes, with the prefix Outmouse.
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
foreach my $dent (sort keys %SEQ){
	open (OUT, ">".$filename.$output."txt");$output++;
	print OUT ">".$dent."\n".$SEQ{$dent}."\n";
	close (OUT);
	$sequence = $SEQ{$dent}; 
	print "$dent\t".length($sequence)."\n";
	$lengthall = $lengthall + length($sequence);
	#print "$dent\t";
	#printf "%-8s %s\t", $dent;
}
print "\nlength of all sequences\t$lengthall\nnumber of genes\t$gencount\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
exit;

