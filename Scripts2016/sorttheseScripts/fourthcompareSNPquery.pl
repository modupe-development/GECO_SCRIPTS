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
open(MATCH,">matches.txt");

my ($dbh, $sth);
my %HashRoss; my %HashHeritage; my %HashConsq;

# CONNECT TO THE DATABASE
print "\n\n\tCONNECTING TO THE DATABASE : $dsn\n\n";
$dbh = DBI->connect($dsn, $user, $passwd) or die "Connection Error: $DBI::errstr\n";

#TABLE
open(C1,"<$ARGV[0]") or die "Can't open file\n";



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CONNECT
my ($i,$j) = 0; 
while (<C1>) {
  chomp;
  my ($chr,$pos,$ref,$alt,$class,$ann, $dbsnp) = split (/\t/,$_,7);
  $HashRoss{$chr}{$pos}{$ref}{$alt} = "$chr\t$pos\t$ref\t$alt\t$class\t$ann\t$dbsnp\n";
}
#my $syntax2 = "select * from variants_result 
#              group by a.library_id, a.chrom,a.position";
#$sth = $dbh->prepare($syntax2);
#$sth->execute or die "SQL Error: $DBI::errstr\n";
#while (my ($chr,$pos,$ref,$alt,$class,$con) = $sth->fetchrow_array){
#  $HashRoss{$chr}{$pos}{$ref}{$alt} = "$chr\t$pos\t$ref\t$alt\t$class\t$con\n";
#}

foreach my $a (keys %HashRoss){
  foreach my $b (keys %{ $HashRoss{$a} } ){
    foreach my $c (keys %{ $HashRoss{$a}{$b} } ){
      foreach my $d (keys %{ $HashRoss{$a}{$b}{$c} } ){
        unless ($HashRoss{$a}{$b}{$c}{$d} =~ /STREAM/) {
            $i++;print MATCH $HashRoss{$a}{$b}{$c}{$d};
        }
      }
    }
  }
}
print "\nTotal records that match $i\nTotal records that don't match $j\n";
#exit;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
exit;


