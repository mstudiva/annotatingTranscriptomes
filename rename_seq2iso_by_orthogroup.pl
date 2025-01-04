#!/usr/bin/perl
use strict;
use warnings;

# Check for correct number of arguments
if (@ARGV != 3) {
    die "Usage: $0 <contig_to_gene_file> <orthogroup_to_gene_file> <output_file>\n";
}

# Assign arguments to variables
my ($contig_to_gene_file, $orthogroup_to_gene_file, $output_file) = @ARGV;

# Hashes to store mappings
my %gene_to_contig;       # GeneID -> ContigID
my %gene_to_orthogroup;   # GeneID -> OrthogroupID

# Read the contig-to-gene file
open(my $ctg_fh, '<', $contig_to_gene_file) or die "Cannot open $contig_to_gene_file: $!";
while (<$ctg_fh>) {
    chomp;
    my ($contig, $gene) = split(/\t/);
    $gene_to_contig{$gene} = $contig;
}
close($ctg_fh);

# Read the orthogroup-to-gene file
open(my $ortho_fh, '<', $orthogroup_to_gene_file) or die "Cannot open $orthogroup_to_gene_file: $!";
while (<$ortho_fh>) {
    chomp;
    my ($orthogroup, $geneA, $geneB) = split(/\t/);
    $gene_to_orthogroup{$geneA} = $orthogroup if $geneA;
    $gene_to_orthogroup{$geneB} = $orthogroup if $geneB;
}
close($ortho_fh);

# Create the output file
open(my $out_fh, '>', $output_file) or die "Cannot open $output_file: $!";
foreach my $gene (keys %gene_to_contig) {
    if (exists $gene_to_orthogroup{$gene}) {
        print $out_fh "$gene_to_contig{$gene}\t$gene_to_orthogroup{$gene}\n";
    }
}
close($out_fh);

print "Output written to $output_file\n";

