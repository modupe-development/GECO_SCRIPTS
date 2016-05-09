#!/usr/bin/perl
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL for extracting stuff from the database
#10/26/2015

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
use strict;
use DBI;

# DATABASE ATTRIBUTES
my $dsn = 'dbi:mysql:transcriptatlas';
my $user = 'frnakenstein';
my $passwd = 'maryshelley';
my $basepath = "/storage2/modupeore17/ChickenTAVariant";
my $statusfile = "$basepath/mystatus.txt";
#open(STATUS,">$statusfile"); print STATUS "libraryid\ttotal\n"; close (STATUS);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
my ($dbh, $sth); my %HashDirectory;
# CONNECT TO THE DATABASE
print "\n\n\tCONNECTING TO THE DATABASE : $dsn\n\n";
$dbh = DBI->connect($dsn, $user, $passwd) or die "Connection Error: $DBI::errstr\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#DATA FILE looking AT WHAT WE HAVE
# CONNECT
#GETTING ALL THE LIBRARIES FROM THE DATABASE.
my $libraries;
my $libras = "select library_id from vw_libraryinfo where species like \"gall\%\";";
$sth = $dbh->prepare($libras); $sth->execute or die "SQL Error: $DBI::errstr\n";

while ( my $row = $sth->fetchrow_array() ) {
	$libraries .= $row.",";
}
$libraries = substr($libraries,0,-1);
my @libraries = split (",", $libraries);

#PARSING EACH FILE OUT OF THE DATABASE. 
foreach my $file (@libraries){
	opendir (DIR, $basepath) or die "Folder \"$basepath\" doesn't exist\n"; 
	my @Directory = readdir(DIR); close(DIR);
	#pushing each subfolder
	foreach (@Directory){
		if ($_ =~ /^\d*$/){
		$HashDirectory{$_}= $_;}
	}
	unless (exists $HashDirectory{$file}){
		mkdir "$basepath/$file";
		my $syntax= "select
			b.variant_class,b.zygosity,b.existing_variant,c.consequence,c.gene_id,
			c.gene_name,c.transcript,c.feature,c.gene_type,b.ref_allele,b.alt_allele,a.line,
			a.tissue,b.chrom,c.aminoacid_change,c.codon_change,a.species,
			a.notes,b.quality,a.library_id,a.total_VARIANTS,a.total_SNPS,a.total_INDELS,b.position,
			c.protein_position
			from vw_libraryinfo a join variants_result b 
				on a.library_id = b.library_id 
			join variants_annotation c 
				on b.library_id = c.library_id and b.chrom = c.chrom and b.position = c.position
			where a.species = \"gallus\" and a.library_id = $file";
	 
		$sth = $dbh->prepare($syntax);
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		open(OUT,">$basepath/$file/$file\.txt");
			
		#TABLE FORMAT
		my $i = 0;
		while ( my @row2 = $sth->fetchrow_array() ) {
		$i++;
			foreach my $list (0..$#row2-1){
				if ((length($row2[$list]) < 1) || ($row2[$list] =~ /^\-$/) ){
					$row2[$list] = "NULL";
				}
				if ($list < 18) {
					print OUT "\'$row2[$list]\',";
				}
				else {
					print OUT "$row2[$list],";
				}
			}
			if ((length($row2[$#row2]) < 1) || ($row2[$#row2] =~ /^\-$/) ){
				$row2[$#row2] = "NULL";
			}
			print OUT "$row2[$#row2]\n";
		}
		open(STATUS, ">>$statusfile");
		print STATUS "$file\t$i\n";
		close (OUT);
	}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
exit;
