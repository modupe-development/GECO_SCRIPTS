#! usr/bin/perl
use File::Basename;

#OBJECTIVE
print "\n\tLength Of Each chromosome in a fasta file\n";

my $input = $ARGV[0];
my $i= 0;
unless(open(FILE,$input)){
	print "File \'$input\' doesn't exist\nSpecify the fasta file\n";
	exit;
}

my @file = <FILE>;
chomp @file;
close (FILE);
my $count = 0;
my %Hashdetails;
foreach my $chr (@file){
	if ($chr =~ /^>/){
		$header = $chr;
	}
	else {
		$length = length($chr);
	}
print "$header\t $length\n";
$newlength = $newlength + $length;
}
print "\n\nTotal length = $newlength\n";

exit;
