#!/usr/bin/perl
# Written by E Meyer (eli.meyer@science.oregonstate.edu) and modified by Michael Studivan (studivanms@gmail)
# Fixed bug that outputted instructions to output file
# Also changed code to ignore descriptions in fasta header, and to parse two-column contaminants list

use strict;
use warnings;
use Bio::SeqIO;

# Get script name
my $scriptname = $0; 
$scriptname =~ s/.+\///g;

# Argument check
if ($#ARGV != 1 || $ARGV[0] eq "-h") {
    print "\nExcludes sequences identified in a user-supplied list from a FASTA file.\n";
    print "Usage: $scriptname list input > output\n";
    print "Where:\tlist:\ta list of sequence IDs with additional data (tab-delimited)\n";
    print "\tinput:\ta FASTA file containing multiple sequences.\n";
    print "\toutput:\tredirected output file (all sequences not named in list)\n\n";
    exit;
}

# Get arguments
my $lfile = $ARGV[0];
my $seqfile = $ARGV[1];

# Read the list of IDs to exclude (extract first column only)
open(my $list_fh, '<', $lfile) or die "Cannot open list file $lfile: $!\n";
my %exclude;
while (<$list_fh>) {
    chomp;
    my ($id, $annotation) = split(/\t/, $_); # Split by tab
    $exclude{$id} = 1;                       # Store the first column as keys
}
close($list_fh);

# Process the FASTA file
my $seq_in = Bio::SeqIO->new(-file => $seqfile, -format => 'fasta');

while (my $seq = $seq_in->next_seq) {
    my $ID = $seq->display_id; # Get FASTA ID
    my $desc = $seq->description;
    my $seq_str = $seq->seq;

    # Skip sequences whose IDs are in the exclude list
    next if exists $exclude{$ID};

    # Print remaining sequences in FASTA format
    print ">$ID $desc\n$seq_str\n";
}

