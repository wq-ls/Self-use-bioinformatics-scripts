#!/usr/bin/perl
use strict;
use warnings;
use File::Path qw(make_path);

# Check if the correct number of arguments is provided
if (@ARGV != 2) {
    die "Usage: $0 <GFF file> <Output directory>\n";
}

# Get positional arguments
my ($file, $Outdir) = @ARGV;

# Remove trailing slash from output directory if present
$Outdir =~ s/\/$//;

# Create output directory if it doesn't exist
unless (-d $Outdir) {
    make_path($Outdir) or die "Failed to create output directory $Outdir: $!";
}

# Hash to store sequence information
my %seqinfor;

# Open and read the GFF file
open my $in, '<', $file or die "Can't open GFF file $file: $!";
while (<$in>) {
    chomp;
    my @c = split /\t/;
    if (@c > 4) {
        if ($c[2] =~ /mRNA/) {
            if ($c[8] =~ /ID=([^\s;]+)/) {
                my $id = $1;
                push @{$seqinfor{$id}{mRNA}}, @c;
            }
        } elsif ($c[2] =~ /CDS/) {
            if ($c[8] =~ /Parent=([^\s;]+)/) {
                my $id = $1;
                push @{$seqinfor{$id}{CDS}}, \@c;
            }
        } elsif ($c[2] =~ /exon/) {
            if ($c[8] =~ /Parent=([^\s;]+)/) {
                my $id = $1;
                push @{$seqinfor{$id}{exon}}, \@c;
            }
        }
    }
}
close $in;

# Initialize statistics variables
my $gene_number = 0;
my $total_mRNA_length = 0;
my $total_exon_number = 0;
my $total_cds_length = 0;
my $total_intron_length = 0;

# Open output files
open my $out1, '>', "$Outdir/mRNA_length.txt" or die "Can't open output file $Outdir/mRNA_length.txt: $!";
open my $out2, '>', "$Outdir/average.txt" or die "Can't open output file $Outdir/average.txt: $!";
open my $out3, '>', "$Outdir/cds_length.txt" or die "Can't open output file $Outdir/cds_length.txt: $!";
open my $out4, '>', "$Outdir/exon_length.txt" or die "Can't open output file $Outdir/exon_length.txt: $!";
open my $out5, '>', "$Outdir/exon_number.txt" or die "Can't open output file $Outdir/exon_number.txt: $!";
open my $out6, '>', "$Outdir/intron_length.txt" or die "Can't open output file $Outdir/intron_length.txt: $!";

# Process each gene
foreach my $title (keys %seqinfor) {
    $gene_number++;
    my $mRNA_length = $seqinfor{$title}{mRNA}[4] - $seqinfor{$title}{mRNA}[3] + 1;
    $total_mRNA_length += $mRNA_length;
    print $out1 "$title\t$mRNA_length\n";

    my $cds_length = 0;
    my $number = @{$seqinfor{$title}{CDS}};
    @{$seqinfor{$title}{CDS}} = sort { $a->[3] <=> $b->[3] } @{$seqinfor{$title}{CDS}};
    $total_exon_number += $number;

    for (my $i = 0; $i < $number; $i++) {
        my $exon_length = $seqinfor{$title}{CDS}[$i][4] - $seqinfor{$title}{CDS}[$i][3] + 1;
        $cds_length += $exon_length;
        print $out4 "$title\t$exon_length\n";
        if ($i >= 1) {
            my $intron_length = $seqinfor{$title}{CDS}[$i][3] - $seqinfor{$title}{CDS}[$i-1][4] - 1;
            print $out6 "$title\t$intron_length\n";
            $total_intron_length += $intron_length;
        }
    }
    $total_cds_length += $cds_length;
    print $out3 "$title\t$cds_length\n";
    print $out5 "$title\t$number\n";
}

# Calculate averages
my $average_mRNA_length = $total_mRNA_length / $gene_number;
my $average_exon_length = $total_cds_length / $total_exon_number;
my $average_cds_length = $total_cds_length / $gene_number;
my $average_exon_number = $total_exon_number / $gene_number;
my $total_intron_number = $total_exon_number - $gene_number;
my $average_intron_length = $total_intron_length / $total_intron_number;
my $total_intron_length2 = $total_mRNA_length - $total_cds_length;
my $average_intron_length2 = $total_intron_length2 / $total_intron_number;

# Print summary statistics
print $out2 <<SUMMARY;
The total number of genes is $gene_number
The average mRNA length is $average_mRNA_length
The average CDS length is $average_cds_length
The average number of exons per gene is $average_exon_number
The average exon length is $average_exon_length
The average intron length is $average_intron_length
The alternative average intron length is $average_intron_length2
The total number of exons is $total_exon_number
The total number of introns is $total_intron_number
The total intron length is $total_intron_length
The alternative total intron length is $total_intron_length2
SUMMARY

# Close output files
close $out1;
close $out2;
close $out3;
close $out4;
close $out5;
close $out6;
