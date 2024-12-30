#!/usr/bin/perl
# Written by E Meyer (eli.meyer@science.oregonstate.edu) and modified by Michael Studivan (studivanms@gmail) for use on FAU's HPC KoKo

use strict;
use warnings;
use Bio::SeqIO;
use File::Basename;

# Check for input arguments
my $qfile = $ARGV[0] or die "This script will remove entries from a specified fasta file (arg1) that are shorter than minimum length (arg2)\n";
my $minlen = $ARGV[1] or die "This script will remove entries from a specified fasta file (arg1) that are shorter than minimum length (arg2)\n";

# Extract the base name and construct the output filename
my ($base, $dir, $ext) = fileparse($qfile, qr/\.[^.]*/);
my $output_filename = $base . "_noshorts.fasta";

# Open input and output filehandles
my $in = Bio::SeqIO->new(
    -file   => $qfile,
    -format => 'Fasta'
);
my $out = Bio::SeqIO->new(
    -file     => ">$output_filename",
    -format   => 'Fasta',
    -alphabet => 'dna'
);

# Counters for retained and discarded sequences
my $good = 0;
my $discarded = 0;

# Process sequences
while (my $seq = $in->next_seq) {
    my $len = $seq->length;
    if ($len >= $minlen) {
        $out->write_seq($seq);
        $good++;
    } else {
        $discarded++;
    }
}

# Summary output
print "noshorts:\nretained:\t$good\ndiscarded:\t$discarded\n";

# Inform user of the output file location
print "Output written to $output_filename\n";

