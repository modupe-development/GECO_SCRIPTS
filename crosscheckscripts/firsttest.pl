#! usr/bin/perl
my $top_folder = "/opt/apache2/frankdec/subdirectories/mapcount_output/blairsch/library_1052/tophat_out"; 
#/opt/apache2/frankdec/subdirectories/mapcount_output/library_103/tophat_out";
my $run_log = "$top_folder/logs/run.log"; my @parse = split('\/\/',$run_log); $run_log = undef; $len = $#parse+1; foreach(@parse){$run_log .= $_; if($len>1){$run_log .="\/"; $len--;}};
		my $genloginfo = `head -n 1 $run_log`;
		my @allgeninfo = split('\s', $genloginfo);

print "$genloginfo\n\n";my $i=0;
foreach my $name(@allgeninfo){
	print "$i\t$name\n";$i++;}		
print "\n\n\n";
if ($allgeninfo[1] =~ /library.*type$/){
	$str = 2; $ann = 4; $ref = 9; $seq = 10;
}
print "TEst print \t ".$allgeninfo[99]."\t you work\n";
 my @numberz =split('_', ((split('\/',$allgeninfo[$seq]))[7]));
                my ($stranded, $annotationfile, $annfileversion, $refgenome, $sequences); #initializing variables
                my $replace = "/home/modupeore17/";
                $allgeninfo[$ann] =~ /^(.*)big_ten.*$/;
                $allgeninfo[$ann] =~ s/$1/$replace/g;
                $allgeninfo[$ref] =~ s/$1/$replace/g;
                print "\n\n$allgeninfo[$ann]\t\t\t$allgeninfo[$ref]\n\n";
                $stranded = $allgeninfo[$str]; # (stranded or not)
                $annotationfile =  uc ( (split('\.',((split("\/", $allgeninfo[$ann]))[-1])))[-1] ); #(annotation file)
                $refgenome = (split('\/', $allgeninfo[$ref]))[-1]; #reference genome name
                $annfileversion = substr(`head -n 1 $allgeninfo[$ann]`, 2); #annotation file version
                unless(length($allgeninfo[$seq++])<=1){ #sequences
                        $sequences = ( ( split('\/', $allgeninfo[$seq]) ) [-1])."\t". ( ( split('\/', $allgeninfo[$seq++]) ) [-1]);
                } else {
                        $sequences = ( ( split('\/', $allgeninfo[$seq]) ) [-1]);
                }
print "$stranded\n$annotationfile\n$refgenome\n$annfileversion\n$sequences\naaa = @numberz\n";

$sequences = substr($sequences,0,-5);
print "$sequences\n";

my $str = "I have a dream";
my $find = "have";
my $replace = "had";
$find = quotemeta $find; # escape regex metachars if present

$str =~ s/$find/$replace/g;

print $str;


my $PICARDDIR="/home/modupeore17/.software/picard-tools-1.136/picard.jar";
my $GATKDIR="/home/modupeore17/.software/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar";
my $VEP="/home/modupeore17/.software/ensembl-tools-release-81/scripts/variant_effect_predictor/variant_effect_predictor.pl";


        my $gatk_version = ( ( split('\/',$GATKDIR)) [-2] );
        my $vep_version = ( ( split('\/',$VEP)) [-4] );

        my $picard_version = ( ( split('\/',$PICARDDIR)) [-2] );


print "\n\n$gatk_version\t$vep_version\t$picard_version\n\n";

 my @numberz =split('\/',$allgeninfo[$seq]);

print "\n\naaa === @numberz";

my $chrdetails = "A[A/T]T";
my $chrdetails = "\L$chrdetails";
my @aaa = split('\[', $chrdetails,2); my @ccc = split('\/', $chrdetails,2);
my @bbb = split('\]', $chrdetails,2); my @ddd = split('\[', "\U$ccc[0]",2); my @eee = split('\]',"\U$ccc[1]",2);

print "\n$chrdetails\n@aaa,  @bbb, @ccc\n$aaa[0]$ddd[1]$bbb[1]/$aaa[0]$eee[0]$bbb[1]\n";
print "\n"."\u$chrdetails\n\n";
my $aq = ((split('\[', $chrdetails,2))[0]);
my $bq = ((split('\]', $chrdetails,2))[1]); my $dq = uc ((split('\[', ((split('\/', $chrdetails,2))[0]),2)) [1]); 
my $eq = uc ((split('\]',((split('\/', $chrdetails,2))[1]),2)) [0]);

print "\n\n$aq$dq$bq/$aq$eq$bq\n";


my $seconddet = "SCAFFOLD-10036	13738	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	User chromosome (SCAFFOLD-10036) not found in GTF;1User mutation (ATT) does not represent a valid base";
my @try = split('\t', $seconddet); print "\n@try\n\n";
foreach (0..$#try){
	if ($try[$_] eq "NA"){
		$try[$_] = "NULL";
	}
}

print "@try\n\n";
