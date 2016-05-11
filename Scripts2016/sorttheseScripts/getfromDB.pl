#!/usr/bin/perl
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL for SNP query for Dr. Schmidt project
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# TABLE VARIABLES
my ($dbh, $sth);
my %HashRoss; my %HashHeritage; my %HashConsq;

# CONNECT TO THE DATABASE
print "\n\n\tCONNECTING TO THE DATABASE : $dsn\n\n";
$dbh = DBI->connect($dsn, $user, $passwd) or die "Connection Error: $DBI::errstr\n";

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CONNECT
my ($i,$j) = 0;
my $length = 0;
my $syntax2 = "set SESSION group_concat_max_len = 1000000";
$sth = $dbh->prepare($syntax2);
$sth->execute or die "SQL Error: $DBI::errstr\n";

my $syntax = "select group_concat(distinct(a.library_id)
              order by a.library_id separator ';'),
              b.chrom, b.position from variants_result a, R1 b
              where a.chrom= b.chrom and a.position =b.position and a.ref_allele = b.ref and a.alt_allele = b.alt group by b.chrom, b.position";

my $syntax1 = "SELECT group_concat(distinct(a.library_id) order by v.library_id separator ';') library,
              group_concat(distinct(v.line) order by v.line separator ';') line ,
              a.chrom chrom, b.position position,
              ifnull(  group_concat(distinct(c.gene_name) order by c.gene_name separator ';') , 'none' ) gene
              FROM bird_libraries v
                INNER JOIN variants_result a
                  ON v.library_id = a.library_id
                INNER JOIN R1 b
                  ON a.chrom = b.chrom and a.ref_allele = b.ref and a.alt_allele = b.alt
                INNER JOIN variants_annotation c
                  ON c.library_id = a.library_id and c.chrom = a.chrom and c.position = a.position
              WHERE c.gene_name is not null
              GROUP BY a.chrom,a.position";

my $syntax3 = "SELECT group_concat(distinct(v.line) order by v.line separator ';') line ,
              a.chrom chrom, b.position position,
              ifnull(  group_concat(distinct(c.gene_name) order by c.gene_name separator ';') , 'none' ) gene
              FROM bird_libraries v
                INNER JOIN variants_result a
                  ON v.library_id = a.library_id
                INNER JOIN R1 b
                  ON a.chrom = b.chrom and a.ref_allele = b.ref and a.alt_allele = b.alt
                INNER JOIN variants_annotation c
                  ON c.library_id = a.library_id and c.chrom = a.chrom and c.position = a.position
              WHERE c.gene_name is not null
              GROUP BY a.chrom,a.position";

my $syntax4 = "select distinct a.consequence from variants_annotation a join bird_libraries b on a.library_id = b.library_id where b.line like \"%oss%\"";

my $syntax5 = "select a.library_id, a.chrom, a.position, a.consequence, a.gene_name from variants_annotation a
              join bird_libraries b on a.library_id = b.library_id where b.line like \"Ross%\" and a.gene_name is not NULL";
    
my $syntax6 = "select a.library_id, a.chrom, a.position, a.consequence, a.gene_name from variants_annotation a
              join bird_libraries b on a.library_id = b.library_id where b.line like \"Heritage\" or b.line like \"Illinois\" and a.gene_name is not NULL";

my $syntax7 = "select a.library_id, a.chrom, a.position, b.ref_allele, b.alt_allele, a.consequence, a.gene_name from temp_ross a
              join variants_result b on a.library_id = b.library_id and a.chrom = b.chrom and a.position = b.position";

my $syntax8 = "SELECT a.chrom chrom, b.position position, 
              ifnull(  group_concat(distinct(c.gene_name) order by c.gene_name separator ';') , 'none' ) gene 
              FROM bird_libraries v 
                INNER JOIN variants_result a
                  ON v.library_id = a.library_id
                INNER JOIN R1 b
                  ON a.chrom = b.chrom and a.ref_allele = b.ref and a.alt_allele = b.alt
                INNER JOIN variants_annotation c
                  ON c.library_id = a.library_id and c.chrom = a.chrom and c.position = a.position
              WHERE c.gene_name is not null and (v.line = \"Illinois\" or v.line = \"Heritage\")
              GROUP BY a.chrom, a.position";
              
my $syntax9 = "SELECT b.chrom chrom, b.position position,                
              ifnull(  group_concat(distinct(b.gene_name) order by b.gene_name separator ';') , 'none' ) gene,
              ifnull(  group_concat(distinct(a.line) order by a.line separator ';') , 'none' ) line
              FROM temp_ross b
                INNER JOIN variants_annotation c
                  ON b.chrom = c.chrom and b.position = c.position
                INNER JOIN bird_libraries a  
                  ON a.library_id = c.library_id where a.line = \"Illinois\" or a.line = \"Heritage\" 
              GROUP BY b.chrom, b.position";              
$sth = $dbh->prepare($syntax9);
$sth->execute or die "SQL Error: $DBI::errstr\n";
open(OUT,">DBout-output.txt");

while ( my ($chr, $pos, $gene,$line) = $sth->fetchrow_array){
  print OUT "$chr\t$pos\t$gene\t$line\n"; $i++;


#open(IN,"<DB-output.txt");
#while (<IN>) {
#  chomp;
#  my ($lib, $chr, $pos, $ref, $alt, $con, $gen) = split /\t/;
#  my $stra = "insert into temp_heritage2 (library_id, chrom,position, ref_allele, alt_allele, consequence, gene_name) values (?,?,?,?,?,?,?)";
#  $sth = $dbh->prepare($stra);
#  $sth->execute($lib,$chr,$pos,$ref, $alt,$con,$gen) or die "SQL Error: $DBI::errstr\n";
  
  
}


print "\nTotal number of records $i\n";
#exit;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
exit;


