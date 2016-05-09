#!/usr/bin/perl
#converts gff file to a tab-delimited file for genes
open(IN,"<",$ARGV[0]) or die "$ARGV[0] can't open";
open (OUT, ">.outputforgffsudo.txt");
while (<IN>){
	chomp;
	@all = split("\t", $_);
	if($all[2] =~ /gene/){
		foreach my $i (0..$#all-1){
			print OUT "$all[$i]\t";
		}
		print OUT "$all[$#all]\n";
	}
}
close(IN);
close(OUT);

#get the type of file and contents need
open(IN1,"<.outputforgffsudo.txt") or die "Can't open";
open (OUT1, ">", $ARGV[1]);
print OUT1 "Protein\tBeg\tEnd\tReference\tOrientation\n";
while (<IN1>){
        chomp;
        @all = split("\t", $_);
        @newall = split("\;", $all[8]);
        foreach my $abc (@newall){
                if ($abc =~ /^gene=.*/){
                        @bcd = split("\=",$abc,2);
                        print OUT1 "$bcd[1]\t$all[3]\t$all[4]\t$all[0]\t$all[6]\n";
                }
        }
}
close(IN1);
`rm -rf .outputforgffsudo.txt`;
close(OUT1);
