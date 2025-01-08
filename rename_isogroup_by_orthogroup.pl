#!/usr/bin/perl
use strict;
use warnings;

# Check for correct number of arguments
if (@ARGV != 3) {
    die "Usage: $0 <orthogroup_to_isogroup_file> <isogroup_to_other_file> <output_file>\n";
}

# Command-line arguments
my ($orthogroup_file, $isogroup_file, $output_file) = @ARGV;

# Hash to store the isogroup to other identifier mapping
my %isogroup_to_other;

# Read isogroup to other identifier table
open(my $isogroup_fh, "<", $isogroup_file) or die "Could not open $isogroup_file: $!";
while (my $line = <$isogroup_fh>) {
    chomp $line;
    my ($isogroup, $other) = split(/\t/, $line);
    $isogroup_to_other{$isogroup} = $other;
}
close($isogroup_fh);

# Hash to store unique output rows
my %unique_rows;

# Read orthogroup to isogroup table and generate output
open(my $orthogroup_fh, "<", $orthogroup_file) or die "Could not open $orthogroup_file: $!";
open(my $output_fh, ">", $output_file) or die "Could not open $output_file: $!";

while (my $line = <$orthogroup_fh>) {
    chomp $line;
    my ($orthogroup, $isogroup) = split(/\t/, $line);

    # Check if isogroup has a mapping to other identifier
    if (exists $isogroup_to_other{$isogroup}) {
        my $other = $isogroup_to_other{$isogroup};
        my $output_line = "$orthogroup\t$isogroup\t$other";

        # Store the output line in the hash to ensure uniqueness
        $unique_rows{$output_line} = 1;
    }
}

# Write unique rows to the output file
foreach my $row (keys %unique_rows) {
    print $output_fh "$row\n";
}

close($orthogroup_fh);
close($output_fh);

__END__
