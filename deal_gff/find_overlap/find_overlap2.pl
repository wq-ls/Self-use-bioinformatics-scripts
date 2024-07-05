#!/usr/bin/perl

=head1 program

  Gene.overlap.pl --find overlap between ref_file and query_files(single || multi) on mRNA&CDS level

=head1 Usage

  perl Gene.overlap.pl ref_file [query_file_1,query_file_2,......]

  ref_file and each query_file have to be normal gff3(no gff2) type

=head1 option

  --num		display the overlap by number,default by decimal

  --locus	regardless of +/- strand,default find overlap on +/- strand separately

  --help	display the help information

=head1 Explain

  if add --num parameter,the meanings of every field as follow:

  ref_Gene_id  strand  scaffold  overlap_num  query_Gene_id(ref_mRNA_len,query_mRNA_len,mRNA_overlap_len;ref_exon_number,query_exon_number;ref_CDS_len,query_CDS_len,CDS_overlap_len)

  if retain default parameter,the meanings of every field as follow:

  ref_Gene_id  strand  scaffold  overlap_num  query_Gene_id(mRNA_overlap_len/ref_mRNA_len,mRNA_overlap_len/query_mRNA_len;ref_exon_number,query_exon_number;CDS_overlap_len/ref_CDS_len,CDS_overlap_len/query_CDS_len)

  CDS in the program means linkage of all exons

=head1 author&version

  qiufeng,qiufeng@genomics.org.cn

  Version:1.0,Date:2010-11-06

  Version:1.1,Date:2010-11-08 add Explain

  Version:1.2,Date:2011-03-01 improve some codes

=head1 Example

  perl Gene.overlap.pl ~/Dmel.gff ~/cflo.gff > Dmel.cflo.overlap

  perl Gene.overlap.pl --num --locus ~/Dmel.gff ~/cflo.gff ~/hsal.gff > Dmel.cflo.hsal.overlap

=cut

use warnings;
use strict;
use Getopt::Long;

my ($locus,$num,$help);
GetOptions(
     "locus"=>\$locus,
     "num"=>\$num,
     "help"=>\$help
);

die `pod2text $0` if (@ARGV==0 || $help);

my $ref_file=shift;my @query_file=@ARGV;

############################################################
###########################Gene#############################
############################################################

my %ref;
open (IN,$ref_file) || die "$!\n";
while(<IN>){
	chomp;
	if(!($_=~/^#/)){
	my @c=split /\t/,$_;
	my $id;
	$id=$c[0].$c[6] if(!($locus));
	$id=$c[0] if($locus);
	my $G_id=$1 if($c[8]=~/^\S+?=(\S+?);/);
	($c[3],$c[4])=($c[4],$c[3]) if($c[3]>$c[4]);
	push @{$ref{$id}{$G_id}},[$c[3],$c[4]];}
}
close IN;

my %query;my $Q_num=0;
foreach my $query_sub_file(@query_file){
open (IN,$query_sub_file) || die "$!\n";
while(<IN>){
	chomp;
	if(!($_=~/^#/)){
	my @c=split /\t/,$_;
	my $id;
	$id=$c[0].$c[6] if(!($locus));
	$id=$c[0] if($locus);
	my $G_id=$1 if($c[8]=~/^\S+?=(\S+?);/);
	($c[3],$c[4])=($c[4],$c[3]) if($c[3]>$c[4]);
	push @{$query{$Q_num}{$id}{$G_id}},[$c[3],$c[4]];}
}close IN;
$Q_num++;}

############################################################
########################find_overlap########################
############################################################

my %RQ;my $overlap=0;my @all_overlap;
foreach my $s(keys %ref){
	foreach my $R_G(keys %{$ref{$s}}){
	my $R_Gene=\@{$ref{$s}{$R_G}};
	push @{$RQ{$R_G}},$R_G;push @{$RQ{$R_G}},$s;
	foreach my $num_ID(keys %query){
	if(defined $query{$num_ID}{$s}){
	foreach my $Q_G(keys %{$query{$num_ID}{$s}}){
my $Q_Gene=\@{$query{$num_ID}{$s}{$Q_G}};
if($R_Gene->[0][0]<=$Q_Gene->[0][1] and $R_Gene->[0][1]>=$Q_Gene->[0][0])
{
#mRNA overlap
 if($R_Gene->[0][0]<=$Q_Gene->[0][0] and $R_Gene->[0][1]>=$Q_Gene->[0][1])
 {$overlap=$Q_Gene->[0][1]-$Q_Gene->[0][0]+1;}
 if($R_Gene->[0][0]>=$Q_Gene->[0][0] and $R_Gene->[0][1]>=$Q_Gene->[0][1])
 {$overlap=$Q_Gene->[0][1]-$R_Gene->[0][0]+1;}
 if($R_Gene->[0][0]<=$Q_Gene->[0][0] and $R_Gene->[0][1]<=$Q_Gene->[0][1])
 {$overlap=$R_Gene->[0][1]-$Q_Gene->[0][0]+1;}
 if($R_Gene->[0][0]>=$Q_Gene->[0][0] and $R_Gene->[0][1]<=$Q_Gene->[0][1])
 {$overlap=$R_Gene->[0][1]-$R_Gene->[0][0]+1;}

 my $R_mRNA_len=$R_Gene->[0][1]-$R_Gene->[0][0]+1;my $Q_mRNA_len=$Q_Gene->[0][1]-$Q_Gene->[0][0]+1;
 push @all_overlap,$Q_G;
 push @all_overlap,$R_mRNA_len;push @all_overlap,$Q_mRNA_len;push @all_overlap,$overlap;
#CDS overlap
 my $R_cds_len=0;my $Q_cds_len=0;
 for(my $i=1;$i<@$R_Gene;$i++){$R_cds_len=$R_cds_len+$R_Gene->[$i][1]-$R_Gene->[$i][0]+1;}
 for(my $k=1;$k<@$Q_Gene;$k++){$Q_cds_len=$Q_cds_len+$Q_Gene->[$k][1]-$Q_Gene->[$k][0]+1;}

 my $cds_overlap=0;my $all_cds_overlap=0;
 for(my $i=1;$i<@$R_Gene;$i++){
 for(my $k=1;$k<@$Q_Gene;$k++){
 if($R_Gene->[$i][0]<=$Q_Gene->[$k][1] and $R_Gene->[$i][1]>=$Q_Gene->[$k][0])
 {
 if($R_Gene->[$i][0]<=$Q_Gene->[$k][0] and $R_Gene->[$i][1]>=$Q_Gene->[$k][1])
 {$cds_overlap=$Q_Gene->[$k][1]-$Q_Gene->[$k][0]+1;}
 if($R_Gene->[$i][0]>=$Q_Gene->[$k][0] and $R_Gene->[$i][1]>=$Q_Gene->[$k][1])
 {$cds_overlap=$Q_Gene->[$k][1]-$R_Gene->[$i][0]+1;}
 if($R_Gene->[$i][0]<=$Q_Gene->[$k][0] and $R_Gene->[$i][1]<=$Q_Gene->[$k][1])
 {$cds_overlap=$R_Gene->[$i][1]-$Q_Gene->[$k][0]+1;}
 if($R_Gene->[$i][0]>=$Q_Gene->[$k][0] and $R_Gene->[$i][1]<=$Q_Gene->[$k][1])
 {$cds_overlap=$R_Gene->[$i][1]-$R_Gene->[$i][0]+1;}
 $all_cds_overlap=$all_cds_overlap+$cds_overlap;
 }}}

 push @all_overlap,@$R_Gene-1;push @all_overlap,@$Q_Gene-1;
 push @all_overlap,$R_cds_len;push @all_overlap,$Q_cds_len;push @all_overlap,$all_cds_overlap;
#combine
 push @{$RQ{$R_G}},[@all_overlap];undef @all_overlap;

}}}}}}

undef %ref;undef %query;

############################################################
########################display_overlap#####################
############################################################

foreach my $x(keys %RQ){

	if(defined $locus){
	printf "%s\t%s\t%d",$RQ{$x}[0],$RQ{$x}[1],@{$RQ{$x}}-2;}

	if(!(defined $locus)){
	my $str;my $scaf;
	if($RQ{$x}[1]=~/(\S+)\+$/){$str="+";$scaf=$1;}
	if($RQ{$x}[1]=~/(\S+)\-$/){$str="-";$scaf=$1;}
	printf "%s\t%s\t%s\t%d",$RQ{$x}[0],$str,$scaf,@{$RQ{$x}}-2;}

	if(defined $num){
	for(my $i=2;$i<@{$RQ{$x}};$i++){
	my $RQ_x=\@{$RQ{$x}};
	printf "\t%s(%d,%d,%d;%d,%d;%d,%d,%d)",
	$RQ_x->[$i][0],$RQ_x->[$i][1],$RQ_x->[$i][2],$RQ_x->[$i][3],
	$RQ_x->[$i][4],$RQ_x->[$i][5],
	$RQ_x->[$i][6],$RQ_x->[$i][7],$RQ_x->[$i][8];}
	printf "\n";}

	if(!(defined $num)){
	for(my $i=2;$i<@{$RQ{$x}};$i++){
	my $RQ_x=\@{$RQ{$x}};
	my $ref_mRNA_r=$RQ_x->[$i][3]/$RQ_x->[$i][1];my $query_mRNA_r=$RQ_x->[$i][3]/$RQ_x->[$i][2];
	my $ref_cds_r=$RQ_x->[$i][8]/$RQ_x->[$i][6];my $query_cds_r=$RQ_x->[$i][8]/$RQ_x->[$i][7];
	printf "\t%s(%5.3f,%5.3f;%d,%d;%5.3f,%5.3f)",
	$RQ_x->[$i][0],$ref_mRNA_r,$query_mRNA_r,$RQ_x->[$i][4],$RQ_x->[$i][5],$ref_cds_r,$query_cds_r;}
	printf "\n";}
}
