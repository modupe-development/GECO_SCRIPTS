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
my $file = "/home/modupeore17/matches";
my $lib = $ARGV[0];
my $no = $ARGV[1];
my $temp2 = $file.$no; my $temp = $file.++$no;
open(MATCH,">$temp");

my ($dbh, $sth);
my %HashRoss; my %HashHeritage; my %HashConsq;

# CONNECT TO THE DATABASE
print "\n\n\tCONNECTING TO THE DATABASE : $dsn\n\n";
$dbh = DBI->connect($dsn, $user, $passwd) or die "Connection Error: $DBI::errstr\n";

#TABLE
open(C1,"<$temp2") or die "Can't open file\n";


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CONNECT
my ($i,$j) = 0; 
while (<C1>) {
  chomp;
  my ($chr,$pos,$ref,$alt,$class,$ann) = split (/\t/,$_,6);
  $HashRoss{$chr}{$pos}{$ref}{$alt} = "$chr\t$pos\t$ref\t$alt\t$class\t$ann\n";
}
#my $syntax2 = "select a.chrom, a.position, a.ref_allele, a.alt_allele, a.variant_class, GROUP_CONCAT(b.consequence) as consequence
#              from variants_result a join variants_annotation b on a.library_id = b.library_id and
#              a.chrom=b.chrom and a.position=b.position and a.library_id = $lib
#              group by a.library_id, a.chrom,a.position";
#$sth = $dbh->prepare($syntax2);
#$sth->execute or die "SQL Error: $DBI::errstr\n";
#while (my ($chr,$pos,$ref,$alt,$class,$con) = $sth->fetchrow_array){
#  $HashRoss{$chr}{$pos}{$ref}{$alt} = "$chr\t$pos\t$ref\t$alt\t$class\t$con\n";
#}

my $syntax = "select a.chrom, a.position, a.ref_allele, a.alt_allele, a.variant_class, GROUP_CONCAT(b.consequence) as consequence
              from variants_result a join variants_annotation b on a.library_id = b.library_id and
              a.chrom=b.chrom and a.position=b.position and a.library_id = $lib
              group by a.library_id, a.chrom,a.position";
$sth = $dbh->prepare($syntax);
$sth->execute or die "SQL Error: $DBI::errstr\n";
while (my ($chr2,$pos2,$ref2,$alt2,$cla2, $con2) = $sth->fetchrow_array){
  if (exists $HashRoss{$chr2}{$pos2}{$ref2}{$alt2}){
    $i++; print MATCH "$chr2\t$pos2\t$ref2\t$alt2\t$cla2\t$con2\n";
  }
}
#foreach my $a (keys %HashRoss){
#  foreach my $b (keys %{ $HashRoss{$a} } ){
#    foreach my $c (keys %{ $HashRoss{$a}{$b} } ){
#      foreach my $d (keys %{ $HashRoss{$a}{$b}{$c} } ){
#        $j++; print NOT $HashRoss{$a}{$b}{$c}{$d}."\n";
#      }
#    }
#  }
#}
print "\nTotal records that match $i\n";
#exit;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
exit;


