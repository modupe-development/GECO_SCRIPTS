#!/usr/bin/perl
use strict;
my $totalgenes = 0;
my $gff = $ARGV[0];
my $fileparse = $ARGV[1]; 
my $count = 1;
my %POSstart = ''; my %POSend=''; my %CHR=''; my %ORN=''; my %GENE=''; my %Gno = ''; my %GINFO=''; my %FILEPATH = ''; my %HTALL = '';
my @allfile; my @header; my $sumofgenes=0;

GFF_FILE();
open(OUT,">includechromdetail.json") or die "can't open the output file";
print OUT "{\n";
open(FILE, "<", $fileparse) or die "$fileparse not real";
@allfile = <FILE>;
my $aaa = shift @allfile; chomp $aaa;
@header = split("\t", $aaa);
foreach(@allfile) {
  chomp;
  my @alli = split("\t",$_,2);
  $alli[0] =~ /^(.*)-(\d+)$/;
  $GINFO{$1}{$2} = $alli[1];
  if (exists $Gno{$1}){
    if ($Gno{$1} < $2){
      $Gno{$1} = $2;
    }
  }else {
    
    $Gno{$1} = $2;
  }
}

foreach my $genename (sort keys %GINFO){
  if (length($genename) > 1){
    print OUT "\t\"$genename\" : [";
    my $counted = 0;
    foreach my $bbb (sort {$a <=> $b} keys %{ $GINFO{$genename} }){
      $counted++; $count++;
      my @details = split("\t", $GINFO{$genename}{$bbb});
      print OUT "\n\t\t{\"chr\" : \"$CHR{$genename}{$bbb}\",\"start\" : \"$POSstart{$genename}{$bbb}\",";
      print OUT "\"stop\" : \"$POSend{$genename}{$bbb}\",\"orn\" : \"$ORN{$genename}{$bbb}\",";
      print OUT "\"$header[1]\" : \"$details[0]\",\"$header[2]\" : \"$details[1]\",";
      print OUT "\"$header[3]\" : \"$details[2]\",\"$header[4]\" : \"$details[3]\",";
      print OUT "\"$header[5]\" : \"$details[4]\",\"$header[6]\" : \"$details[5]\",";
      print OUT "\"$header[7]\" : \"$details[6]\",\"$header[8]\" : \"$details[7]\",";
      print OUT "\"$header[9]\" : \"$details[8]\",\"$header[10]\" : \"$details[9]\",";
      print OUT "\"$header[11]\" : \"$details[10]\",\"$header[12]\" : \"$details[11]\",";
      print OUT "\"$header[13]\" : \"$details[12]\",\"$header[14]\" : \"$details[13]\" }";
      if ($counted < $Gno{$genename}) {
        print OUT ",";
      } 
    }
    print OUT "\n\t]";
    if ($count < $sumofgenes) {
      print OUT ",\n";
    }
  }
}
print OUT "\n}\n";
print "$sumofgenes\t$count\n";
close (OUT);
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
