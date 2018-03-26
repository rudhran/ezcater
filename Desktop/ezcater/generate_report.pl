use strict;
use warnings;

use NameReport;
use Data::Dumper;

use Getopt::Long;

sub Usage {
	print "Valid script usage: perl $0 --file <input file contains name list>\n";
	exit();
}

my $name_list_file;

GetOptions(
	"file=s" , \$name_list_file,
) || Usage();

unless ($name_list_file) {
	Usage();
}

my $name_list = ConstructNameDS({ FILENAME => $name_list_file });

UniqueNameCountReport({NAMELIST => $name_list});

UniqueNewNameList({NAMELIST => $name_list});



#print Dumper $unique_name_report;