#!/usr/bin/perl
use strict;

my $gff = $ARGV[0];
my $fileparse = $ARGV[1]; 

my %POSstart = ''; my %POSend=''; my %CHR=''; my %ORN=''; my %GENE=''; my %GINFO=''; my %FILEPATH = ''; my %HTALL = '';
my @allfile; my @header; my $sumofgenes=0;

GFF_FILE();
open(OUT,">includechromdetail.txt") or die "can't open the output file";
open(FILE, "<", $fileparse) or die "$fileparse not real";
@allfile = <FILE>;
@header = split("\t", shift @allfile, 2);
print OUT $header[0]."\tCHR\tSTART\tSTOP\tORN\t".$header[1];
foreach(@allfile) {
  chomp;
  my @alli = split("\t",$_,2);
  my @gene = split("\-",$alli[0]);
  
  print OUT "$gene[0]\t$CHR{$gene[0]}{$gene[1]}\t$POSstart{$gene[0]}{$gene[1]}\t$POSend{$gene[0]}{$gene[1]}\t$ORN{$gene[0]}{$gene[1]}\t$alli[1]\n"; 
}
close(OUT);
#subroutine

sub GFF_FILE {
  open(GFF,"<",$gff) or die "$gff can't open";
  while (<GFF>){
    chomp;
    my @all = split("\t", $_);
    my @newall = split("\;", $all[8]);
    if($all[2] =~ /gene/){
      foreach my $abc (@newall){
        if ($abc =~ /^gene=.*/){
          my @bcd = split("\=",$abc,2);
#          if (exists $HTALL{$bcd[1]}){
            $sumofgenes++;
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
#          }
        }
      }
    }
  }
  close (GFF);
}
