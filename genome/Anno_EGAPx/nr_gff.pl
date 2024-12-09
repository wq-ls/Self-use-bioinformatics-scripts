#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use File::Basename qw(dirname basename);
use FindBin qw($Bin);
use Getopt::Long;

my ($Cutoff, $Mark, $Score_file, $Direction, $Outdir, $Help,);
my ($Usage);
GetOptions(
	"cutoff:i"=>\$Cutoff,
	"Mark:s"=>\$Mark,
	"score:s"=>\$Score_file,
	"direction:s"=>\$Direction,
	"outdir:s"=>\$Outdir,
	"Help"=>\$Help
);

$Cutoff ||=1;
$Direction ||="T";
$Mark ||="CDS";
$Outdir ||= ".";

$Usage = "
Name:
	$0;

Description:
	Cluster the genes based on the coordinates, and get the non-redundant set.

Contact & Version:
	Li Jianwen, lijianwen\@genomics.org.cn
	Version: 1.4,  Date: 2010.09.26

Options:
	perl $0 [options] <inputgff_file(s)> 
	--direction <T/F>	cluster genes on + and - strands separately, default = T;
	--cutoff <num>		the overlap cutoff for clustering, default = 1;
	--mark <str>		Set the mark of the gff file(column 3), default = CDS;
	--score <str>		Set the score file, and use the score instead of CDS length for choosing, format: id\\tscore or genewise file;
	--outdir <str>		Set the output directory;
	--Help			Print this help information.

Example:
	perl $0 all.gff
	perl $0 1.gff 2.gff 3.gff
	perl $0 --score score.lst gene.gff

";

# Version 1.3 2010-09-15	set output dir; Debug &GetScore();


if (@ARGV<1 || $Help){
	print "$Usage";
	exit;
}

my @files = @ARGV;
my %gene;
my %record; 
my %score;
my @result;

&GetScore(\%score, $Score_file) if ($Score_file);

&ReadGff(\%gene, \%score, \%record, \@files, $Direction, $Mark, $Score_file);

my @cluster;
my $begin;
my $end;

foreach my $scaffold (sort keys %gene){
	my @ids = sort {$gene{$scaffold}{$a}[0][3] <=> $gene{$scaffold}{$b}[0][3]} (keys %{$gene{$scaffold}}); ##sort the genes by coordinate
	foreach my $id (@ids){
		if (!@cluster){ ##Set up the fist cluster for a scaffold
			$begin = $gene{$scaffold}{$id}[0][3];
			$end = $gene{$scaffold}{$id}[0][4];
			push @cluster, $id;
		}else{
			## if a gene invovled in the cluster or overlap with the cluster
			if ($gene{$scaffold}{$id}[0][4] <= $end || ($end - $gene{$scaffold}{$id}[0][3] + 1) >= $Cutoff ){  
				$end = ($gene{$scaffold}{$id}[0][4] > $end ) ? $gene{$scaffold}{$id}[0][4] : $end;
				push @cluster, $id;
			}else{ ## Previous cluster is OK, Get the non-redundant gene 
				&GetNr(\%gene, \%score, \@cluster, $scaffold, \%record, \@result, \@cluster, $Cutoff);
				$begin = $gene{$scaffold}{$id}[0][3];
				$end = $gene{$scaffold}{$id}[0][4];
				@cluster = ();  ## Set up a new cluster
				push @cluster, $id;
			}
		}
	}
	## The last cluster of a scaffold
	&GetNr(\%gene, \%score, \@cluster, $scaffold, \%record, \@result, \@cluster, $Cutoff) if (@cluster);  
	@cluster = ();
}

## Output results
my ($basename);
$basename = basename($files[0]);
$basename .= ".all" if (@files > 1);

open (OUT, ">$Outdir/$basename.nr.gff") || die $!;
print OUT $result[0];
close OUT;

open (OUT, ">$Outdir/$basename.cluster") || die $!;
print OUT $result[1];
close OUT;

open (OUT, ">$Outdir/$basename.uncluster") || die $!;
print OUT $result[2];
close OUT;

##################################################
##################################################
sub ReadGff{
	my ($gene_p, $score_p, $record_p, $files_p, $direction, $mark, $score_file) = @_;
	foreach my $file (@$files_p){
		open (IN, $file) || die $!;
		while (<IN>){
			chomp;
			next if (/^#/);
			my @c = split /\t/, $_;
			next unless ($c[2] =~ /mRNA|transcript/ || $c[2] eq $mark);
			my $id = $1 if ($c[8] =~ /=(\S+?);/);
			my $scaffold = $c[0];
			$scaffold .= $c[6] if ($direction eq "T");
			push @{$gene_p->{$scaffold}{$id}}, [@c];
			$score_p->{$id} += ($c[4] - $c[3] + 1) if ($c[2] eq $mark && !$score_file);
			$record_p->{$scaffold}{$id} .= "$_\n";
		}
	close IN;
	}
}

################################################
sub GetNr{
	my ($gene_p, $score_p, $cluster_p, $scaffold, $record_p, $result_p, $original_cluster_p, $cutoff) = @_;
	my @new_cluster;

	## end the recursion
	if (@$cluster_p == 1){
		$result_p->[0] .= $record_p->{$scaffold}{$cluster_p->[0]};
		if (@$original_cluster_p == 1){
			$result_p->[2] .= shift @{$cluster_p};
			$result_p->[2] .= "\n";
		}else{
			$result_p->[1] .= &GetReference($original_cluster_p, $cluster_p->[0], $gene_p, $score_p, $scaffold);
		}
		return;
	}
	
	## initialize the record for the best;
	my $best_order = -1;
	my $best = 0;
	my $best_id = "";

	## Get the best in the cluster;
	for (my $i = 0; $i < @$cluster_p; $i++){
		my $id = $cluster_p->[$i];
		if ($best < $score_p->{$id}){
			$best_order = $i;
			$best = $score_p->{$id};
			$best_id = $id;
		}
	}

	$result_p->[0] .= $record_p->{$scaffold}{$best_id};
	$result_p->[1] .= &GetReference($original_cluster_p, $best_id, $gene_p, $score_p, $scaffold);
	
	## remove the genes which overlap with the best one
	for (my $i = 0; $i < @$cluster_p; $i++){
		my $id = $cluster_p->[$i];
		next if ($i == $best_order);
		push @new_cluster, $id if ($i < $best_order && $gene_p->{$scaffold}{$id}[0][4] < $gene_p->{$scaffold}{$best_id}[0][4] && $gene_p->{$scaffold}{$id}[0][4] - $gene_p->{$scaffold}{$best_id}[0][3] +1 < $cutoff);
		push @new_cluster, $id if ($i > $best_order && $gene_p->{$scaffold}{$best_id}[0][4] < $gene_p->{$scaffold}{$id}[0][4] && $gene_p->{$scaffold}{$best_id}[0][4] - $gene_p->{$scaffold}{$id}[0][3] +1 < $cutoff);
	}
	# recursion, remove the redundant genes and build a new cluster, get the best in the cluster
	&GetNr($gene_p, $score_p, \@new_cluster, $scaffold, $record_p, $result_p, $original_cluster_p, $cutoff) if (@new_cluster);
}

#################################################
sub GetReference{
	my ($original_cluster_p, $id0, $gene_p, $score_p, $scaffold) = @_;
	my @new_cluster;
	my $result;
	my ($coor0, $coor1) = ($gene_p->{$scaffold}{$id0}[0][3], $gene_p->{$scaffold}{$id0}[0][4]);

	foreach my $id (@$original_cluster_p){
		push @new_cluster, $id unless ($gene_p->{$scaffold}{$id}[0][4] < $coor0 || $gene_p->{$scaffold}{$id}[0][3] > $coor1);
	}

	@new_cluster = sort {$score_p->{$b} <=> $score_p->{$a}} @new_cluster;
	$result = join "\t", @new_cluster;
	$result .= "\n";
	return $result;
}

################################################
sub GetScore{
	my ($score_p, $file)= @_;

	open (IN, $file) || die $!;
	if ($file =~ /genewise$/){
		while (<IN>){
			if (/^Bits/){
				my $line = <IN>;
				my ($score, $gene) = (split /\s+/, $line)[0,1];
				$score_p->{$gene} = $score;
			}
	 	}
	}else{
		while (<IN>){
			chomp;
			my @c = split;
			$score_p->{$c[0]} = $c[1];
		}
	}
	close IN;
}
