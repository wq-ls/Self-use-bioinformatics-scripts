use strict;
use warnings;
use Bio::SeqIO;

## --help
# check input
my $infile = $ARGV[0] or die "Usage: perl script.pl <input_file> [output_file]\n";
my $outfile = $ARGV[1];

# open input
my $in  = Bio::SeqIO->new(-file => $infile, -format => 'Fasta');

# output check
my $out;
if ($outfile) {
    $out = Bio::SeqIO->new(-file => ">$outfile", -format => 'Fasta');
} else {
    $out = Bio::SeqIO->new(-fh => \*STDOUT, -format => 'Fasta');
}

while (my $seq = $in->next_seq()) {
    my $sequence = $seq->seq;

    # remove non-ATCGN
    $sequence =~ s/[^ATCGNatcgn]//g;

    $seq->seq($sequence);
    $out->write_seq($seq);
}

$in->close();
$out->close() if $outfile;

