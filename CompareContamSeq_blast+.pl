#!/usr/bin/perl
# Written by E Meyer (eli.meyer@science.oregonstate.edu) and modified by Michael Studivan (studivanms@gmail) for use on FAU's HPC KoKo
# Also includes update from blastall to blast+

# -- check arguments and print usage statement
$scriptname=$0; $scriptname =~ s/.+\///g;
$usage = <<USAGE;
Identifies most likely origin of each sequence by comparing against a
protein sequence database from a single close relative, and a protein database
from a likely contaminant. e.g. for corals, A. digitifera would be a
good choice for a close relative, and Symbiodinium would be a likely contaminant.

Each sequence is assigned to the source which it matches best, or to neither
if it matches neither database.

Usage: $scriptname -q queries -s score -t target_db -c contam_db
Required arguments:
        queries:    FASTA-formatted file of DNA sequences (e.g. transcripts)
        score:      bit-score threshold (matches this high or higher count as a match)
        target_db:  BLAST-formatted protein database of a closely related species
        contam_db:  BLAST-formatted protein database of an expected contaminant
USAGE

# -- module and executable dependencies
$mod1="File::Which";
unless(eval("require $mod1")) {print "$mod1 not found. Exiting\n"; exit;}
use File::Which;
$mod1="Getopt::Std";
unless(eval("require $mod1")) {print "$mod1 not found. Exiting\n"; exit;}
use Getopt::Std;
$mod1="Bio::SearchIO";
unless(eval("require $mod1")) {print "$mod1 not found. Exiting\n"; exit;}
use Bio::SearchIO;
$mod1="Bio::SeqIO";
unless(eval("require $mod1")) {print "$mod1 not found. Exiting\n"; exit;}
use Bio::SeqIO;

# get variables from input
getopts('q:s:t:c:h');
if (!$opt_q || !$opt_s || !$opt_t || !$opt_c || $opt_h) {
    print "\n", "-"x60, "\n", $scriptname, "\n", $usage, "-"x60, "\n\n";
    exit;
}
$qfile = $opt_q;
$score = $opt_s;
$tdb = $opt_t;
$tfname = $tdb;
$tfname =~ s/.+\///g;
$hno = 3;
$cpu = 20;
$cdb = $opt_c;

@dba = ($tdb, $cdb);

# BLAST search section
foreach $d (@dba) {
    print "Comparing $qfile against $d...\n";
    $ofn = $d;
    $ofn =~ s/.+\///g;
    $ofn =~ s/\.[a-z]+$//g;
    $ofn = "$ofn.br";
    system("blastx -db $d -query $qfile -out $ofn -num_descriptions $hno -num_alignments $hno -num_threads $cpu");
    print "Done.\n";

    # Extract and store information about best matches
    $report = new Bio::SearchIO(-file => $ofn, -format => "blast", report_type => 'blastx');
    while ($result = $report->next_result) {
        my $query_id = (split(/\s+/, $result->query_name))[0];
        $hitno = 0;
        while ($hit = $result->next_hit) {
            if ($hit->bits < $score) { next; }
            $hitno++;
            if ($hitno > 1) { next; }
            $hh{$query_id}{$d}{"hit"} = $hit->accession;
            $hh{$query_id}{$d}{"score"} = $hit->bits;
        }
    }
}

# Decisions and output section
open(TAB, ">origin_summary.tab");
foreach $qs (sort(keys(%hh))) {
    $constat = 0;
    $conid = "";
    %qh = %{$hh{$qs}};
    @sda = sort { $qh{$b}{"score"} <=> $qh{$a}{"score"} } (keys(%qh));
    $nsda = @sda;

    if ($nsda < 1) { $constat = "NA"; }
    elsif ($sda[0] eq $tdb) { $constat = 0; }
    else {
        $constat = 1;
        $conid = $sda[0];
    }
    if ($constat == 0) { $idh{$qs} = "target"; }
    else { $idh{$qs} = $conid; }
}

# Write out sequences and summary output
$tarcount = $concount = $unkcount = 0;
$inseq = new Bio::SeqIO(-file => $qfile, -format => "fasta");
while ($seq = $inseq->next_seq) {
    $seqcount++;
    $qs = (split(/\s+/, $seq->display_id))[0];
    if (exists($idh{$qs})) {
        $qi = $idh{$qs};
        $qi =~ s/.+\///g;
        $qi =~ s/\.\w+$//;
        $destfile = $qi . ".screened.fasta";
        print TAB $qs, "\t", $qi, "\n";
        if ($idh{$qs} eq "target") { $tarcount++; }
        else { $concount++; }
    } else {
        $destfile = "nomatch.screened.fasta";
        print TAB $qs, "\t", "no match", "\n";
        $unkcount++;
    }
    $outseq = new Bio::SeqIO(-file => ">>$destfile", -format => "fasta");
    $outseq->write_seq($seq);
}

print "\n", $seqcount, " sequences input.\n";
print $tarcount, " of these matched ", $tfname, " more closely than any contaminants.\n";
print $concount, " matched contaminants more closely than ", $tfname, ".\n";
print $unkcount, " matched none of the supplied DB (nomatch.screened.fasta).\n\n";

