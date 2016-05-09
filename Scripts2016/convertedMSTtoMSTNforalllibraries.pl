#!/usr/bin/perl
opendir(DIR,$ARGV[0]) or die "Folder \"$ARGV[0]\" doesn't exist\n";
my @Directory = readdir(DIR);
close(DIR); my $number = 0;
#pushing each subfolder
foreach my $new (@Directory){
  if ($new =~ /^\d*$/){
      open(FILE,"<", $ARGV[0]."/".$new."/".$new.".txt") or die;
	`mkdir "$ARGV[1]/$new"`;
      open(STO,">",$ARGV[1]."/".$new."/".$new.".txt") or die;
      print "$new , ";
      while (<FILE>) {
	@line = split("\'\,\'", $_, 7);
	foreach $j (0..4){
		print STO "$line[$j]\'\,\'";
	}
	if ($line[5] =~ /^MST$/){
		$number++;
		print STO "MSTN\'\,\'";
	}
	else {
		print STO "$line[5]\'\,\'";
	}
	print STO $line[6];
	}
  }
}
print "\n\nThis is how many corrected :$number\n";
