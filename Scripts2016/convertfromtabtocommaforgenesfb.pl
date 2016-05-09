#!/usr/bin/perl

$input = $ARGV[0];
open(DIR,"<$input");
while (<DIR>){
	chomp;
	@line = split("\t",$_,2);
	print $line[0].",";
}
