#!/usr/bin/perl
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Parsing libraries to fastbit.
#Specify the folder path for input and the output name
#03/08/2016

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
use strict;
use DBI;

# DATABASE ATTRIBUTES

my $basepath = $ARGV[0];
my $finalpath = "/storage2/modupeore17/FBTranscriptAtlas";
my $statusfile = "$finalpath/myFBstatus";
open(STDOUT, '>', "$statusfile\.log") or die "Log file doesn't exist";
open(STDERR, '>', "$statusfile\.err") or die "Error file doesn't exist";
 
#open(STATUS,">$statusfile"); print STATUS "libraryid\ttotal\n"; close (STATUS);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
my %HashDirectory;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opendir (DIR, $basepath) or die "Folder \"$basepath\" doesn't exist\n"; 
my @Directory = readdir(DIR); close(DIR);
#pushing each subfolder
foreach (@Directory){
	if ($_ =~ /^\d*$/){$HashDirectory{$_}= $_;}
}
foreach my $key (sort {$a <=> $b} keys %HashDirectory) {
	#import to FastBit file
	my $execute = "nice -n 12 ardea -d $finalpath/$ARGV[1] -m \"
		class:char,
		zygosity:char,
		dbsnp:char,
		consequence:char,
		geneid:char,
		genename:char,
		transcript:char,
		feature:char,
		genetype:char,
		ref:char,
		alt:char,
		line:char,
		tissue:char,
		chrom:char,
		aachange:char,
		codon:char,
		species:key,
		notes:text, 
		quality:double,
		library:int,
		variant:int,
		snp:int,
		indel:int,
		position:int,
		proteinposition:int\" -t $basepath/$key/$key\.txt";
	system($execute);
}
#GETTING ALL THE LIBRARIES FROM THE DATABASE.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
close STDOUT; close STDERR;
exit;
