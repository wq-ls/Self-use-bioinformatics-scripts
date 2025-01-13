use strict;
use warnings;
use Bio::SeqIO;

# 检查是否提供了输入文件
my $infile = $ARGV[0] or die "Usage: perl script.pl <input_file> [output_file]\n";
my $outfile = $ARGV[1];  # 可选的输出文件

# 打开输入文件
my $in  = Bio::SeqIO->new(-file => $infile, -format => 'Fasta');

# 如果提供了输出文件名则写入文件，否则写入标准输出
my $out;
if ($outfile) {
    $out = Bio::SeqIO->new(-file => ">$outfile", -format => 'Fasta');
} else {
    $out = Bio::SeqIO->new(-fh => \*STDOUT, -format => 'Fasta');
}

# 遍历每一个序列
while (my $seq = $in->next_seq()) {
    my $sequence = $seq->seq;

    # 去除非ATCGN的字符
    $sequence =~ s/[^ATCGNatcgn]//g;

    # 更新序列内容并写入文件或标准输出
    $seq->seq($sequence);
    $out->write_seq($seq);
}

# 关闭输入句柄
$in->close();
$out->close() if $outfile;  # 如果写入到文件，则关闭输出句柄
