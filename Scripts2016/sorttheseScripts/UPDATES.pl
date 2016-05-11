#!/usr/bin/perl

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR inputs.pl

=pod

=head1 NAME

$0 -- Insert tables to transcriptatlas

=head1 SYNOPSIS

I.pl [--help] [--manual]

=head1 DESCRIPTION

Insert results from CHICKENSNPS and PENGUIN to the database : transcriptatlass
 
=head1 OPTIONS

=over 3

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-man, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries (all standard in most Perl installs).
   DBI
   DBD::mysql
   Getopt::Long
   Pod::Usage

=head1 AUTHOR

Written by Modupe Adetunji, 
Center for Bioinformatics and Computational Biology Core Facility, University of Delaware.

=head1 REPORTING BUGS

Report bugs to amodupe@udel.edu

=head1 COPYRIGHT

Copyright 2015 MOA.  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

Please acknowledge author and affiliation in published work arising from this script's 
usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

=cut

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CODE FOR insert_results.pl

use strict;
use DBI;
use DBD::mysql;
use Getopt::Long;
use Pod::Usage;

#ARGUMENTS
my($in1,$help,$manual);
GetOptions (	
                               "h|help"        =>      \$help,
                                "man|manual"	=>      \$manual );

# VALIDATE ARGS
pod2usage( -verbose => 2 )  if ($manual);
pod2usage( -verbose => 1 )  if ($help);

#making sure the input file is parsable

# DATABASE ATTRIBUTES
my $dsn = 'dbi:mysql:transcriptatlas';
my $user = 'frnakenstein';
my $passwd = 'maryshelley';

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# DATABASE VARIABLES
my ($dbh, $sth, $syntax,@row, $row);

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CONNECT TO THE DATABASE
print "\n\n\tCONNECTING TO THE DATABASE : $dsn\n\n";
$dbh = DBI->connect($dsn, $user, $passwd) or die "Connection Error: $DBI::errstr\n";
my $filepath = "/home/modupeore17/PENGUIN";
#OPENING FILES
#open (TABLE, "<$filepath/Results.txt") or die "Can't open file $filepath/Results.txt\n";
#open(GENES, "<$filepath/Genes.txt") or die "Can't open file $filepath/Genes.txt\n";
#open(ISOFORMS, "<$filepath/Isoforms.txt") or die "Can't open file $filepath/Isoforms.txt\n";
#open(IDGENES, "<$filepath/IdsGenes.txt") or die "Can't open file $filepath/IdsGenes.txt\n";
#open(VLIST, "<$filepath/VResults.txt") or die "Can't open file $filepath/VResults.txt\n";
#open(VSUMMARY, "<$filepath/VSummary.txt") or die "Can't open file $filepath/VSummary.txt\n";
open(BIRDS, "<metadata.txt") or die "Can't open file metadata.txt\n";
open(BIRD, "<metadata.txt") or die "Can't open file metadata.txt\n";


# INSERT INTO DATABASE
#  #transcript_summary
#  $sth = $dbh->prepare("insert into transcripts_summary (library_id, total_reads, mapped_reads, unmapped_reads, deletions, 
#  	insertions, junctions, isoforms, genes, info_prep_reads, date, status ) values (?,?,?,?,?,?,?,?,?,?,?,?)");
#  my $status = "done";
#  $/ = "done\n"; 
#  while (<TABLE>){
#  	chomp;
#  	my ($lib_id1, $total, $mapped, $unmapped, $deletions, $insertions, $junctions, $isoforms, $genes, $prep, $date) = split /\t/;
#  	#print "$lib_id1, $total, $mapped, $unmapped, $deletions, $insertions, $junctions, $isoforms, $genes, $prep, $date\n";
#  	$sth -> execute($lib_id1, $total, $mapped, $unmapped, $deletions, $insertions, $junctions, $isoforms, $genes, $prep, $date, $status );
#  }
#  $/ ="\n";
#  close TABLE;

# #genes_fpkm 
# $sth = $dbh->prepare("insert into genes_fpkm (library_id, tracking_id, class_code, nearest_ref_id, gene_id, 
# 	gene_short_name, tss_id, chrom_no, chrom_start, chrom_stop, length, coverage, fpkm, fpkm_conf_low, 
# 	fpkm_conf_high, fpkm_status ) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
# while (<GENES>){
# 	chomp;
#     my ($lib_id2, $track, $class, $ref_id, $gene, $gene_name, $tss, $chrom_no, $chrom_start, $chrom_stop, $length, 
#     	$coverage, $fpkm, $fpkm_low, $fpkm_high, $fpkm_stat ) = split /\t/;
# 	$sth ->execute($lib_id2, $track, $class, $ref_id, $gene, $gene_name, $tss, $chrom_no, $chrom_start, $chrom_stop, 
# 		$length, $coverage, $fpkm, $fpkm_low, $fpkm_high, $fpkm_stat );
# }
# close GENES;
# 
# #isoforms_fpkm
# $sth = $dbh->prepare("insert into isoforms_fpkm (library_id, tracking_id, class_code, nearest_ref_id, gene_id, 
# 	gene_short_name, tss_id, chrom_no, chrom_start, chrom_stop, length, coverage, fpkm, fpkm_conf_low, 
#  	fpkm_conf_high, fpkm_status ) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
# while (<ISOFORMS>){
# 	chomp;
#     my ($lib_id3, $track2, $class2, $ref_id2, $gene2, $gene_name2, $tss2, $chrom_no2, $chrom_start2, $chrom_stop2, $length2, 
#     	$coverage2, $fpkm2, $fpkm_low2, $fpkm_high2, $fpkm_stat2 ) = split /\t/;
# 	$sth ->execute($lib_id3, $track2, $class2, $ref_id2, $gene2, $gene_name2, $tss2, $chrom_no2, $chrom_start2, $chrom_stop2, 
# 		$length2, $coverage2, $fpkm2, $fpkm_low2, $fpkm_high2, $fpkm_stat2 );
# } 
# close ISOFORMS;

#  #geneids
#  $sth = $dbh->prepare("insert into gene_id (no_id, ensembl_geneid, entrez_geneid ) values (?,?,?)");
#  while (<IDGENES>){
#  	chomp;
#  	my ($no_id, $ensembl, $entrez) = split /\t/;
#  	$sth ->execute($no_id, $ensembl, $entrez );
#  } 
#  close IDGENES;

#VARIANT_summary 
my $number =0;
my %Hashresults; my %Variantresults;
my $table = $ARGV[0];
$syntax = "select distinct(library_id) from $table";
$sth = $dbh->prepare($syntax);
$sth->execute or die "SQL Error: $DBI::errstr\n";
while ($row = $sth->fetchrow_array() ) {
    if($row =~ /\d*DE$/){
        my $newrow = substr($row,0,-2);
        $Hashresults{$row} = $newrow;
    }
}
foreach my $keys (keys %Hashresults){
	my $script = "update $table set library_id=$Hashresults{$keys} where library_id=$Hashresults{$keys}";
    print $script."\t";
    $number++;
    $sth = $dbh->prepare($script);
    $sth->execute();
    print "done\n";
}
print "$number\n";
#$syntax = "select library_id from variants_summary";
#$sth = $dbh->prepare($syntax);
#$sth->execute or die "SQL Error: $DBI::errstr\n";
#$number = 0;
#while ($row = $sth->fetchrow_array() ) {
#	$Variantresults{$row} = $number; $number++;
#}
# $sth = $dbh->prepare("insert into variants_summary (library_id, total_VARIANTS, total_SNPS, total_INDELS, date ) 
# 	values (?,?,?,?,?)");
# while (<VSUMMARY>){
# 	chomp;
#     my ($lib_id5, $totalvariants, $totalsnps, $totalindels, $date) = split /\t/;
#     print $lib_id5;
#     unless (exists $Variantresults{$lib_id5}){
#     	if (exists $Hashresults{$lib_id5}){
# 			$sth ->execute($lib_id5, $totalvariants, $totalsnps, $totalindels, $date );
# 		}
# 	}
# } 
# close VSUMMARY;

#VARIANT_list
#$sth = $dbh->prepare("insert into variants_result (library_id, chrom, position, ref_allele, alt_allele, 
#	quality, ensembl_gene, entrez_gene, gene_name, transcript,feature, gene_type, consequence, protein, 
#	protein_position, codon_change, zygosity, existing_variant) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
#while (<VLIST>){
#	chomp;
#	my ($lib_id4, $chrom2, $position2, $ref_allele, $alt_allele, $quality, $ensembl_gene, $entrez_gene, $gene_name, $transcript,
#		$feature, $gene_type, $consequence, $protein, $protein_position, $codon_change, $zygosity, $existing_variant ) = split /\t/;
#  if (exists $Hashresults{$lib_id4}){
#    	$sth ->execute($lib_id4, $chrom2, $position2, $ref_allele, $alt_allele, $quality, $ensembl_gene, $entrez_gene,
#		$gene_name, $transcript, $feature, $gene_type, $consequence, $protein, $protein_position, $codon_change, 
#		$zygosity, $existing_variant );
#	}
#} 
#close VLIST;

#schmidt_id
#$sth = $dbh->prepare("insert into schmidtId (auto_id, library_id) values (?,?)");
#while(<BIRD>){
#    chomp;
#    print "$_\n";my @allofit = split("\t", $_);
# 	if ($allofit[0] =~ /^\d/){
#        my $lib_id6 = $allofit[0]."DE"; #library_id
#        $sth ->execute($allofit[0],$lib_id6);
#    }
#}
 #BIRD libraries 
 #$sth = $dbh->prepare("insert into bird_libraries (library_id, bird_id, species, line, tissue, method, index_, chip_result, scientist,date, notes) 
 #	values (?,?,?,?,?,?,?,?,?,?,?)");
 #lib_id	bird_id	species	line	tissue
 #tissue_id	rna_id	method  index	chip_date_submitted
 #chip_result	seq_date_submitted	seq_date_approved	scientist	timestamp
 #notes

 #while (<BIRDS>){
 #	chomp;
 #	my @allofit = split("\t", $_);
 #	if ($allofit[0] =~ /^\d/){ 
 #		my $lib_id6 = $allofit[0]."DE"; #library_id
 #		if (length($allofit[1]) < 1){$allofit[1] = undef; }#bird_id
 #       if (length($allofit[2]) < 1){$allofit[2] = undef; }#species
 #		if (length($allofit[3]) < 1){$allofit[3] = undef; }#line
 #       if (length($allofit[4]) < 1){$allofit[4] = undef; }#tissue
 #       if (length($allofit[7]) < 1){$allofit[7] = undef; } #method
 #       if (length($allofit[8]) < 1){$allofit[8] = undef; } #index_
 #       if (length($allofit[10]) < 1){$allofit[10] = undef; } #chip_result
 #       if (length($allofit[13]) < 1){$allofit[13] = undef; } #scientist
 #       if (length($allofit[14]) < 1){$allofit[14] = undef; } #date
 #       if (length($allofit[15]) < 1){$allofit[15] = undef; } #notes		
 #		$sth = $dbh->prepare("update bird_libraries set bird_id=\"$allofit[1]\", species=\"$allofit[2]\", line=\"$allofit[3]\",
 #                             tissue=\"$allofit[4]\",method=\"$allofit[7]\", index_=\"$allofit[8]\", chip_result=\"$allofit[10]\",
 #                             scientist=\"$allofit[13]\",date=\"$allofit[14]\",notes=\"$allofit[15]\" where library_id=$allofit[0]");
 #       $sth->execute();
 #	}
 #} 
 #close BIRDS;


# DISCONNECT FROM THE DATABASE
print "\n\tDISCONNECTING FROM THE DATABASE : $dsn\n\n";
$sth-> finish;
$dbh->disconnect();

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
exit;

