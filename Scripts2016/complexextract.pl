#!/usr/bin/perl

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR KaKs_ratios.pl

=pod

=head1 NAME

$0 -- Comprehensive pipeline : Inputs Alignment file (Bam format), Reference file used and GFF file and generates 
a folder of all the different genes in separate files with the KaKs ratios.
: Leverages the KaKs_Calculator command line tool.
  
=head1 SYNOPSIS

KaKs_ratios.pl -b <xxx.bam> -r <ref.fa> -g <gff.gff> -o <OUTPUTDIR> -n name [--help] [--manual]

=head1 DESCRIPTION

Accepts bam file, reference file and gff file to calculate the KaKs_ratios implemented by the KaKs_calculator.
 
=head1 OPTIONS

=over 3

=item B<-b, --bam>=FILE

Mapping/Alignment file.  (Required)

=item B<-r, -ref, --reference>=FILE

Reference fasta file used to create the bam (i.e. mapping file).  (Required)

=item B<-g, --gff>=FILE

GFF file to determine the different genes (version GFF3).  (Required)

=item B<-o, -out, --output>=FOLDER

output directory where all the libraries will be stored.  (Required)

=item B<-n, --name>=NAME

Name of the file for output.  (Optional)

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-man, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries (all standard in most Perl installs).
   Getopt::Long
   Pod::Usage
   File::Basename;
   Time::localtime;
   Time::Piece;
   File::stat;
   DateTime;

=head1 AUTHOR

Written by Modupe Adetunji, 
Center for Bioinformatics and Computational Biology Core Facility, University of Delaware.

=head1 REPORTING BUGS

Report bugs to amodupe@udel.edu

=head1 COPYRIGHT

Copyright 2016 MOA.  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

Please acknowledge author and affiliation in published work arising from this script's usage

=cut

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CODE FOR KaKs_ratios.pl
use strict;
use File::Basename;
use Getopt::Long;
use Time::localtime;
use File::stat;
use DateTime;
use Pod::Usage;


# #CREATING LOG FILES
my $std_out = '/home/modupeore17/.LOG/KaKs-'.`date +%m-%d-%y_%T`; chomp $std_out; $std_out = $std_out.'.log';
my $std_err = '/home/modupeore17/.LOG/KaKs-'.`date +%m-%d-%y_%T`; chomp $std_err; $std_err = $std_err.'.err';
my $jobid = "KaKs-".`date +%m-%d-%y_%T`;
my $progressnote = "/home/modupeore17/.LOG/progressnote".`date +%m-%d-%y_%T`; chomp $progressnote; $progressnote = $progressnote.'.txt'; 

open(STDOUT, '>', "$std_out") or die "Log file doesn't exist";
open(STDERR, '>', "$std_err") or die "Error file doesn't exist";
 
# #ARGUMENTS
my($help,$manual,$gff,$ref,$bam, $out, $name);

GetOptions (	
                                "g|gff=s"       =>      \$gff,
                                "r|ref|reference=s"       =>      \$ref,
                                "b|bam=s"       =>      \$bam,
                                "o|out|output=s"       =>      \$out,
                                "n|name=s"       =>      \$name,
                                "h|help"        =>      \$help,
                                "man|manual"	=>      \$manual );

# #VALIDATE ARGS
pod2usage( -verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required argument(s) are not found.\n", -exitval => 2, -verbose => 1)  if (! $gff || ! $bam || ! $ref || ! $out );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#PATHS
my $KAKS = "~/.software/KaKs_Calculator2.0/src/KaKs_Calculator";

#INITIALIZE 
my %POSstart = ''; my %POSend=''; my %CHR=''; my %ORN=''; my %GENE=''; my %SEQ=''; my %FILEPATH = '';
my $prefix;

#Making OUTPUT DIRECTORY[IES].
`mkdir $out`;
if ($name) {
  $prefix = $name;
}
else {
  $prefix = fileparse($bam, qr/\.[^.]*(\.bam)?$/);
}
my $newpath = $out."/".$prefix;
`mkdir $newpath`; chdir $newpath;
#STARTING
#INITIALIZING FILES
print `date`. "initializing files\n";
GFF_FILE();
BAMFILE();
REFERENCE();
my $sum=0;
#MAIN FLOW
#EXTRACT ALL GENE LOCATIONS FROM REFERENCE FILE
foreach my $genename (sort keys %GENE ){
  foreach my $number (1..$GENE{$genename}){
    open(OUTREF,">", $genename."-".$number."_ref.nuc");
    
    my $count = $POSend{$genename}{$number}-$POSstart{$genename}{$number}+1;
    my $refseq = substr($SEQ{$CHR{$genename}{$number}},$POSstart{$genename}{$number}-1,$count);
    if ($ORN{$genename}{$number} =~ /REV/) {
      $refseq=reverse($refseq);
	$refseq =~ tr/ACGTacgt/TGCAtgca/;
    }
    print OUTREF $refseq."\n";
    close OUTREF;
  }
}
print "TIME ".`date`. "proc ref done\n";

#EXTRACT ALL GENE LOCATIONS FROM BAM FILE
foreach my $genename (sort keys %GENE ){
  foreach my $number (1..$GENE{$genename}){    
    my $extractsam ="samtools mpileup -uf $ref aln.sorted.bam -r $CHR{$genename}{$number}:$POSstart{$genename}{$number}-$POSend{$genename}{$number} | bcftools view -cg - | vcfutils.pl vcf2fq > $genename-$number.pep";
    `$extractsam`;
    FASTQTOFASTA("$genename-$number.pep", $CHR{$genename}{$number});
    open(FASTA, "<$genename-$number.fna");
    my @filecontent = <FASTA>; close (FASTA);
    open(OUTSAM,">", $genename."-".$number."_sam.nuc");
    my $count = $POSend{$genename}{$number}-$POSstart{$genename}{$number}+1;
    my $sampleseq = substr($filecontent[1],$POSstart{$genename}{$number}-1,-1);
    if ($ORN{$genename}{$number} =~ /REV/) {
      $sampleseq=reverse($sampleseq);
	$sampleseq =~ tr/ACGTacgt/TGCAtgca/;
    }
    print OUTSAM $sampleseq."\n";
    close OUTSAM;
  }
}
print "TIME ".`date`. "proc sample done\n";
#COMBINE REF AND SAMPLE FILES WITH HEADER
foreach my $genename (sort keys %GENE ){
  foreach my $number (1..$GENE{$genename}){
    my $fileloc = $genename."-".$number;
    $sum++; $FILEPATH{$sum} = $fileloc;
    my $concat = "cat $genename\n".$fileloc."_ref.nuc ".$fileloc."_sam.nuc > $fileloc.axt";
    `$concat`;
  }
}
print "TIME ".`date`. "concat done\n";

#KAKSCALCULATOR for all the axt files.
foreach my $axt (sort keys %FILEPATH){
  my $runkaks = "$KAKS -i $FILEPATH{$axt}.axt -o $FILEPATH{$axt}.kaks -m NG -m LWL -m LPB -m MLWL -m MLPB -m GY -m YN -m MYN -m MS -m MA -m GNG -m GLWL -m GLPB -m GMLWL -m GMLPB -m GYN -m GMYN";
  `$runkaks`;
}
print "TIME ".`date`. "kaks done\n";

#CLEANUP
#All the nucleotide files
`rm -rf *nuc`;
#All the peptide files
`rm -rf *pep`;
#All fasta files
`rm -rf *fna`;
#All AXT files
`rm -rf *axt`;


#SUBROUTINES
#converts gff file to a tab-delimited file for genes
sub GFF_FILE {
  my $i=0;
  open(GFF,"<",$gff) or die "$gff can't open";
  while (<GFF>){
    chomp;
    my @all = split("\t", $_);
    my @newall = split("\;", $all[8]);
    if($all[2] =~ /gene/){
      foreach my $abc (@newall){
        if ($abc =~ /^gene=.*/){
          my @bcd = split("\=",$abc,2);
          if (exists $GENE{$bcd[1]}){
            $GENE{$bcd[1]}=$GENE{$bcd[1]}+1;
          }
          else {
            $GENE{$bcd[1]}=1;
          }
          $POSstart{$bcd[1]}{$GENE{$bcd[1]}} = $all[3];
          $POSend{$bcd[1]}{$GENE{$bcd[1]}} = $all[4];
          $CHR{$bcd[1]}{$GENE{$bcd[1]}} = $all[0];
          if ($all[6]=~/^\+/) {
            $ORN{$bcd[1]}{$GENE{$bcd[1]}} = "FOR";
          }
          else {
            $ORN{$bcd[1]}{$GENE{$bcd[1]}} = "REV";
          }
        }
      }
    }
  }
  close (GFF);
print "TIME ".`date`. "gff done\n";
}

sub REFERENCE {
  $/= ">";
  open(REF,"<", $ref);
  while (<REF>){
    my @pieces = split /\n/;
    my $header = $pieces[0];
    my $seq = ''; my $qua = '';
    foreach my $num (1.. $#pieces){
      $seq .= $pieces[$num];
    }
    $SEQ{$header}=$seq;
  }
  $/="\n";
  close (REF);
print "TIME ".`date`. "ref done\n";
}

sub BAMFILE {
  my $samsort = "samtools sort $bam aln.sorted";
  my $samindex = "samtools index aln.sorted.bam";
  `$samsort`;`$samindex`;
print "TIME ".`date`. "bam file done\n";
}

sub FASTQTOFASTA {
  my $fastqout = fileparse($_[0], qr/\.[^.]*(\.gz)?$/);
  open(OUTF, "> $fastqout.fna") or die $!;
  $/ = "\@".$_[1];
  open (FASTQ, $_[0]) or die "$_[0] can't open";
  my @fastqfile = <FASTQ>;
  shift(@fastqfile);
  foreach my $entry (@fastqfile){
    my @pieces = split(/\n/, $entry);
    my $header = ">".$_[1].$pieces[0];
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
    print OUTF "$header\n$seq\n";
  }
  close FASTQ; close OUTF;
  $/ = "\n";
}
