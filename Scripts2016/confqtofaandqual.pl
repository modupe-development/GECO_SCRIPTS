#!/usr/bin/perl -w

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR creating a seperate fasta and quality score files from fastq file.pl

=pod

=head1 NAME

$0 -- to convert the fastq to fasta file and keep the quality scores in a seperate file as well

=head1 SYNOPSIS

confqtofaandqual.pl --fq file.fastq[.gz] -tag xxx [--zip] [--help] [--manual]

=head1 DESCRIPTION

Accepts one fastq files. Convert to fasta and quality score file.
The sequences are extracted to an output fasta and quality score file.
This handles only paired end & single reads properly.

=head2 FASTQ FORMAT

Default: Sequence name is all characters between beginning '@' and first space or '/'.  Also first 
character after space or '/' must be a 1 or 2 to indicate pair relationship.  
Compatible with both original Illumina (Casava version 1.7 and previous) and newer
(Casava >= 1.8) formatted headers:
  @B<HWUSI-EAS100R:6:73:941:1973#0>/I<1>
  @B<EAS139:136:FC706VJ:2:2104:15343:197393> I<2>:Y:18:ATCACG

=head1 OPTIONS

=over 3

=item B<-1, -fq, -fastq, --in1>=FILE

One input file must be specified (e.g. fastqfile.fq ).  (Required) 

=item B<-2, -tag, --in2>=FILE

The common header of the fastq reads (only 1 to 5 characters needed(e.g chr ).  (Required)

=item B<-z, --zip>

Specify that input is gzipped fastq (output files will also be gzipped).  Slower, but space-saving.  (Optional)

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries (all standard in most Perl installs).
   IO::Compress::Gzip
   IO::Uncompress::Gunzip
   Getopt::Long
   File::Basename
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

# CODE FOR confqtofaandqual.pl

use strict;
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS
my($in1,$in2,$zip,$help,$manual);

GetOptions (
                                "1|fa|fasta|in1=s"       =>      \$in1,
                                "2|tag|in2=s"       =>      \$in2,
				"z|zip"         =>      \$zip,
                                "h|help"        =>      \$help,
                                "m|manual"      =>      \$manual);

# VALIDATE ARGS
pod2usage(-verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required argument -1 or -2 is not found.\n", -exitval => 2, -verbose => 1)  if (! $in1 || ! $in2);

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$/ = "\@".$in2;

# PARSE OUTPUT FILEBASE
my $out = fileparse($in1, qr/\.[^.]*(\.gz)?$/);

# FILE HANDLES
my ($DATA,$OUT1, $OUT2);

# OPEN INPUT FILE(s)(in1 &/ in2)
if($zip) {
   $DATA = IO::Uncompress::Gunzip->new( $in1 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
}
else {
   open ($DATA,$in1) || die $!;
}

#OPEN OUTPUT FILE(s)
if($zip){
   $OUT1 = IO::Compress::Gzip->new( "$out.fna.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
   $OUT2 = IO::Compress::Gzip->new( "$out.qua.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
}
else {
   open($OUT1, "> $out.fna") or die $!;
   open($OUT2, "> $out.qua") or die $!;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##
#  if (/^@(\S+[\/ ][12].*)$/){
my @fastqfile = <$DATA>;
shift(@fastqfile);
foreach my $entry (@fastqfile){
  my @pieces = split(/\n/, $entry);
  my $header = ">".$in2.$pieces[0];
  my $seq = ''; my $qua = '';
  my $check = 0;
  foreach my $num (1.. $#pieces){
    if ($pieces[$num] =~ /^\+$/) {
      $check = 1; next;
    }
    if ($check == 0) {
      $seq .= $pieces[$num];
    }
    elsif ($check == 1) {
      $qua .= $pieces[$num];
    }
  }
  print $OUT1 "$header\n$seq\n";
  print $OUT2 "$header\n$qua\n";
}
close $DATA; close $OUT1; close $OUT2;
$/ = "\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

