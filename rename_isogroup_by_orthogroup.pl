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
while (<$isogroup_fh>) {
    chomp;
    my ($isogroup_id, $other_identifier) = split /\t/;
    $isogroup_to_other{$isogroup_id} = $other_identifier;
}
close($isogroup_fh);

# Process orthogroup to isogroup table and create the output
open(my $orthogroup_fh, "<", $orthogroup_file) or die "Could not open $orthogroup_file: $!";
open(my $output_fh, ">", $output_file) or die "Could not open $output_file: $!";

while (<$orthogroup_fh>) {
    chomp;
    my ($orthogroup_id, $isogroup_A, $isogroup_B) = split /\t/;

    # Check if the isogroup has a corresponding identifier
    if (exists $isogroup_to_other{$isogroup_A}) {
        print $output_fh "$orthogroup_id\t$isogroup_to_other{$isogroup_A}\n";
    }
    if (exists $isogroup_to_other{$isogroup_B}) {
        print $output_fh "$orthogroup_id\t$isogroup_to_other{$isogroup_B}\n";
    }
}

close($orthogroup_fh);
close($output_fh);

print "Processing complete. Output saved to $output_file.\n";

