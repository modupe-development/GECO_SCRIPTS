#!/usr/bin/perl

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR GECOinserttranscriptome.pl

=pod

=head1 NAME

$0 -- Comprehensive pipeline : Inputs frnakenstein results from tophat and cufflinks and generates a metadata which are all stored in the database : transcriptatlas
: Performs variant analysis using a suite of tools from the output of frnakenstein and input them into the database.

=head1 SYNOPSIS

GECOinserttranscriptome.pl [--help] [--manual]

=head1 DESCRIPTION

Accepts all folders from frnakenstein output.
 
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

Please acknowledge author and affiliation in published work arising from this script's usage
=cut

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CODE FOR 
use strict;
use File::Basename;
use DBI;
use Getopt::Long;
use Time::localtime;
use Pod::Usage;
use Time::Piece;
use File::stat;
use DateTime;


#ARGUMENTS
my($help,$manual,$in1);
GetOptions (	
                                "h|help"        =>      \$help,
                                "man|manual"	=>      \$manual );

# VALIDATE ARGS
pod2usage( -verbose => 2 )  if ($manual);
pod2usage( -verbose => 1 )  if ($help);


# DATABASE ATTRIBUTES
my $dsn = 'dbi:mysql:transcriptatlas';
my $user = 'frnakenstein';
my $passwd = 'maryshelley';
my ($sth, $dbh, $variantclass);
$dbh = DBI->connect($dsn, $user, $passwd) or die "Connection Error: $DBI::errstr\n";
my %GECOdetails;
my %Altdetails;
my %Decision;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  my $syntax = "select library_id, chrom, position, ref_allele, alt_allele from variants_result where variant_class is NULL";
  $sth = $dbh->prepare($syntax);
  $sth->execute or die "SQL Error: $DBI::errstr\n";
  my $incompletes = undef; my $count=0; my @columntoremove;
  while ( my ($library_id, $chrom, $position, $ref, $alt) = $sth->fetchrow_array() ) {
    $GECOdetails{$library_id}{$chrom}{$position} = $ref;
    $Altdetails{$library_id}{$chrom}{$position} = $alt;
  }
my $i=0;
foreach my $libs (sort keys %GECOdetails){
  if ($libs =~ /\d+/){
    foreach my $chr (sort keys % {$GECOdetails{$libs}}){
      foreach my $post (sort keys % {$GECOdetails{$libs}{$chr}}){
        my $reff= $GECOdetails{$libs}{$chr}{$post};
        my $altt= $Altdetails{$libs}{$chr}{$post};
        
        if (length $reff== length $altt){
          $variantclass = "SNV";
        }
        elsif (length $reff > length ($altt)) {
          $variantclass = "deletion";
        }
        elsif (length $reff < length ($altt)) {
          $variantclass = "insertion";
        }
        else {
          print "second False variant, cross-check asap\n"; exit;
        }
        $syntax = "update variants_result set variant_class = \"$variantclass\" where library_id = $libs and chrom = \"$chr\" and position = $post";
        $sth = $dbh->prepare($syntax);
        $sth ->execute();
        $i++;
        #$Decision{$libs}{$chr}{$post} = $variantclass;
      }
    }
  }
}
#foreach my $libs (sort keys %GECOdetails){
#  if ($libs =~ /\d+/){
#    foreach my $chr (sort keys % {$GECOdetails{$libs}}){
#      foreach my $post (sort keys % {$GECOdetails{$libs}{$chr}}){
#        print "$libs\t$chr\t$post\t";
#        print "$GECOdetails{$libs}{$chr}{$post}\t";
#        print "$Altdetails{$libs}{$chr}{$post}\t";
#        print "$Decision{$libs}{$chr}{$post}\n";
#      }
#    }
#  }
#}
        
  print "total changed = $i\n";     
  print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
exit;
