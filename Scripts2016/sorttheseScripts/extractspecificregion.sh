#!usr/bin/perl -w
use strict;

my $file = $ARGV[0];

`samtools sort $file`;
`samtools index $file`;
`samtools idxstats $file`;
`samtools view`;

samtools sort pineal_merged.bam pineal_merged.sorted
samtools index pineal_merged.sorted.bam 
samtools idxstats pineal_merged.sorted.bam
samtools view pineal_merged.sorted.bam chr1:134930000-135017000

