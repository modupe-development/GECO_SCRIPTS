

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CODE FOR 
#use strict;
use File::Basename;
use DBI;
use Getopt::Long;
use Time::localtime;
use Pod::Usage;
use Time::Piece;
use File::stat;
use DateTime;


#file path for input THIS SHOULD BE CONSTANT
$in1 = "/storage2/modupeore17/TAVariant/ChickenTAVariant/";

#DATABASE ATTRIBUTES
my $dsn = 'dbi:mysql:transcriptatlas';
my $user = 'frnakenstein';
my $passwd = 'maryshelley';

#OPENING FOLDER
opendir(DIR,$in1) or die "Folder \"$in1\" doesn't exist\n"; 
my @Directory = readdir(DIR);
close(DIR);
#pushing each subfolder
foreach (@Directory){
  if ($_ =~ /^\d.*$/){
      push (@NewDirectory, $_);
  }
}
print @NewDirectory;
#print "\n\n\tCONNECTING TO THE DATABASE : $dsn\t".`date`."\n\n";
$dbh = DBI->connect($dsn, $user, $passwd) or die "Connection Error: $DBI::errstr\n";

foreach my $NewFolder (@NewDirectory) {
  $executemouse = undef;
  my $input = $in1.$NewFolder."/".$NewFolder.".txt";
  open(NEW,$input) or die "Folder \"$input\" doesn't exist\n";
  
  while (<NEW>) { 
    @info = split (",",$_);
    foreach (@info) {$_ =~ /^'(chr.*)\'$/; $chr = $1;}
    $class = substr($info[0],1,-1);print $class; 
    $position = $info[$#info-1]; 
    $sth = $dbh->prepare("update variants_result set variant_class = \"$class\" where library_id = $NewFolder and chrom = \"$chr\" and position = $position");
    $sth ->execute();
  }
}
