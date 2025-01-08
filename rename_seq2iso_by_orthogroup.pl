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
open(my $ctg_fh, '<', $contig_to_gene_file) or die "Could not open $contig_to_gene_file: $!";
while (my $line = <$ctg_fh>) {
    chomp $line;
    my ($contig, $gene) = split(/\t/, $line);
    $gene_to_contig{$gene} = $contig;
}
close($ctg_fh);

# Read the orthogroup-to-gene file
open(my $orth_fh, '<', $orthogroup_to_gene_file) or die "Could not open $orthogroup_to_gene_file: $!";
while (my $line = <$orth_fh>) {
    chomp $line;
    my ($orthogroup, $gene) = split(/\t/, $line);
    $gene_to_orthogroup{$gene} = $orthogroup;
}
close($orth_fh);

# Hash to store unique output rows
my %unique_rows;

# Generate output based on mappings
open(my $output_fh, '>', $output_file) or die "Could not open $output_file: $!";
foreach my $gene (keys %gene_to_contig) {
    if (exists $gene_to_orthogroup{$gene}) {
        my $contig = $gene_to_contig{$gene};
        my $orthogroup = $gene_to_orthogroup{$gene};
        my $output_line = "$contig\t$gene\t$orthogroup";

        # Store the output line in the hash to ensure uniqueness
        $unique_rows{$output_line} = 1;
    }
}

# Write unique rows to the output file
foreach my $row (keys %unique_rows) {
    print $output_fh "$row\n";
}

close($output_fh);

__END__
