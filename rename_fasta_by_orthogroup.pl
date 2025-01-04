#!/usr/bin/perl
use strict;
use warnings;

# Check arguments
if (@ARGV != 3) {
    die "Usage: perl rename_fasta_by_orthogroup.pl <orthogroup_table> <input_fasta> <output_fasta>\n";
}

# Input files
my ($orthogroup_file, $input_fasta, $output_fasta) = @ARGV;

# Step 1: Read the orthogroup table and create a mapping
my %gene_to_orthogroup;
open my $table, '<', $orthogroup_file or die "Could not open orthogroup file: $!";
while (<$table>) {
    chomp;
    my ($orthogroup_id, $gene_a, $gene_b) = split /\t/;
    $gene_to_orthogroup{$gene_a} = $orthogroup_id if $gene_a;
    $gene_to_orthogroup{$gene_b} = $orthogroup_id if $gene_b;
}
close $table;

# Step 2: Process the FASTA file
open my $in_fasta, '<', $input_fasta or die "Could not open input FASTA file: $!";
open my $out_fasta, '>', $output_fasta or die "Could not open output FASTA file: $!";

my $write_seq = 0;   # Flag to determine if the sequence should be written
my $seq_header = ""; # Store the header of the sequence

while (<$in_fasta>) {
    chomp;
    if (/^>(\S+)/) { # Match FASTA header (contig ID)
        my $full_contig_id = $1;
        
        # Extract gene ID (assuming it's the first part of the contig ID, split by '_')
        my ($gene_id) = split /_/, $full_contig_id;
        
        if (exists $gene_to_orthogroup{$gene_id}) {
            $write_seq = 1;
            $seq_header = ">" . $gene_to_orthogroup{$gene_id};
            print $out_fasta "$seq_header\n"; # Write renamed header
        } else {
            $write_seq = 0;
        }
    } elsif ($write_seq) {
        print $out_fasta "$_\n"; # Write sequence
    }
}

close $in_fasta;
close $out_fasta;

print "Renaming complete! Output written to $output_fasta\n";

