#! usr/bin/perl
my $top_folder = "/home/modupeore17/.LOG/output-08-24-15_11:14:54.err";
open (FILE, "<$top_folder");
my %Hasht = '';
my $number = 0;
while(<FILE>){
	if(/(\d+)DE/){
		$Hasht{$1} = $number++;
	}
}
foreach my $tes (sort {$a <=> $b} keys %Hasht){
	print "$tes\n";
}

