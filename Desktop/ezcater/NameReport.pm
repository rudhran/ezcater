package NameReport;

use strict;
use warnings;
use vars qw(@ISA @EXPORT);
use Data::Dumper;

require Exporter;

@ISA = qw(Exporter);
# Expose only the functions accessed by the script
@EXPORT = qw(ConstructNameDS UniqueNameCountReport UniqueNewNameList);

###########################################################################################
# ReadFileContent
#
#	Description:
#		This function takes filename as an argument, reads the file and returns the content
#		of the file.
#
#	ARGS:
#		$args : Hash Reference of data structure passed to the function
#			Keys:
#				FILENAME => Name of the file to be read
#
#
#	Return Value:
#		String - full content of the file
#############################################################################################
sub ReadFileContent {
	my ($args) = @_;
	
	my $file_content;
	local $/;
	my $file_handle;

	open $file_handle, $args->{FILENAME} or die "Cannot open file '$args->{FILENAME}' for read: $!\n";
	$file_content = <$file_handle>;
	close $file_handle;
	
	return $file_content;
}

###########################################################################################
# ConstructNameDS
#
#	Description:
#		This function takes file content and constructs the data structure to generate report
#
#	ARGS:
#		$args : Hash Reference of data structure passed to the function
#			Keys:
#				FILENAME => Name of the file to be read
#
#
#	Return Value:
#		Hashref of the data sturcture
#############################################################################################
sub ConstructNameDS {
	my ($args) = @_;
	my $file_content = ReadFileContent($args);
	
	my @records = grep { /^[a-z]+, [a-z]+ \-\-/i} split (/\r?\n/, $file_content);
	
	map { s/ \-\-(.+?)$// } @records;
	
	return \@records;
	#print Dumper $file_content;
}

sub UniqueNameCountReport {
	my ($args) = @_;
	
	my @names = @{$args->{NAMELIST}};
	my $fullname;
	my $firstname;
	my $lastname;
	
	foreach my $name (@names) {
		my ($last, $first) = split /, /, $name;
		$fullname->{$name} += 1;
		$firstname->{$first} += 1;
		$lastname->{$last} += 1;
	}
	
	my $uniquefullnamecount = 0;
	foreach my $name (keys %$fullname) {
		$uniquefullnamecount++ if $fullname->{$name} == 1;
	}
	
	my $uniquefirstnamecount = 0;
	foreach my $name (keys %$firstname) {
		$uniquefirstnamecount++ if $firstname->{$name} == 1;
	}

	my $uniquelastnamecount = 0;
	foreach my $name (keys %$lastname) {
		$uniquelastnamecount++ if $lastname->{$name} == 1;
	}

	print "Unique name count (Q1):\n\n";
	print "There are $uniquefullnamecount unique full name\n";
	print "There are $uniquefirstnamecount unique first name\n";
	print "There are $uniquelastnamecount unique last name\n";

	print "\nTop 10 firstname list (Q2):\n";
	my @sortedfirstnamekeys = sort { $firstname->{$b} <=> $firstname->{$a} } (keys %$firstname);
	
	foreach my $name (@sortedfirstnamekeys[0..9]) {
		print "$name ($firstname->{$name})\n";
	}
	
	print "\nTop 10 lastname list (Q3):\n";
	my @sortedlastnamekeys = sort { $lastname->{$b} <=> $lastname->{$a} } (keys %$lastname);
	
	foreach my $name (@sortedlastnamekeys[0..9]) {
		print "$name ($lastname->{$name})\n";
	}
	#print Dumper \@sortedfirstnamekeys;
	
	#print Dumper \$firstname;
##	return {
#		UNIQUEFULLNAMECOUNT => $uniquefullnamecount,
#		UNIQUEFIRSTNAMECOUNT => $uniquefirstnamecount,
#		UNIQUELASTNAMECOUNT => $uniquelastnamecount
#	}
}


sub UniqueNewNameList {
	my ($args) = @_;

	my @names = @{$args->{NAMELIST}};
	my $fullname;
	my $firstname;
	my $lastname;

	my $count = 0;
	my @uniquename;

	foreach my $name (@names) {
		my ($last, $first) = split /, /, $name;
		if (!$fullname->{$name} && !$firstname->{$first} && !$lastname->{$last}) {
			push (@uniquename, $name);
		}
		$fullname->{$name} = 1;
		$firstname->{$first} = 1;
		$lastname->{$last} = 1;
	}
	
	my @firstname;
	my @lastname;
	foreach my $name (@uniquename[0..24]) {
		my ($last, $first) = split /, /, $name;
		push @lastname, $last;
		push @firstname, $first;
	}

	my @newlist;
	my $j;
	for (my $i=0; $i<25; $i++ ) {
		$j = $i + 1;
		$j = 0 if ($j == 25);
		push @newlist , "$lastname[$i], $firstname[$j]";
		$j--;
	}

	print "\nNewly generated list Q(4):\n";
	foreach my $name (@newlist) {
		print "$name\n";
	}
}