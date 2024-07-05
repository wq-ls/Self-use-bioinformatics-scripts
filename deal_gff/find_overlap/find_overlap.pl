#!/usr/bin/perl
#Author:Fan Wei; BGI,2006-02-26

#Include Modules
use strict;
use Data::Dumper;
use Getopt::Long;

#Instructions and advisions of using this program
my $program_name=$1 if($0=~/([^\/]+)$/);
my $usage=<<USAGE;
This program find overlap between block sets
At current it accept psl and gff format as input,
but you need to use .psl or .gff to mark the file

Usage: $program_name  <ref_file> <pre_file>
	-details	output middle details to screen
	-help		output help information to screen

Contact: Fan wei, fanw\@genomics.org.cn
	Quanfei Huang, huangqf\@genomics.org.cn

Modify Date: 2009-7-13

Examples:

 perl ../bin/find_overlap.pl Genbank_Bombyx_mori_cDNA_model.psl silkworm_premasked.bgf.psl > silkworm_premasked.bgf.psl.overlap
 perl ../bin/find_overlap.pl Genbank_Bombyx_mori_cDNA_model.psl silkworm_premasked.bgf.gff > silkworm_premasked.bgf.gff.overlap


USAGE

#################-Main-Function-#################

#get options and parameters
my %opts;
GetOptions(\%opts,"details!","help!");
die $usage if ( @ARGV < 2 || exists $opts{"help"} );

##Constant and global variables
my $ref_file=shift;
my $pre_file=shift;
my ( %Ref, %Pre );

read_psl($ref_file,\%Ref) if($ref_file=~/\.psl$/);
read_gff($ref_file,\%Ref) if($ref_file=~/\.(gff|gff2|gff3|gtf)$/);
print STDERR "read ref_file done\n" if(exists $opts{details});

read_psl($pre_file,\%Pre) if($pre_file=~/\.psl$/);
read_gff($pre_file,\%Pre) if($pre_file=~/\.(gff|gff2|gff3|gtf)$/);
print STDERR "read pre_file done\n" if(exists $opts{details});

find_overlap(\%Ref,\%Pre);
print STDERR "find overlap done\n" if(exists $opts{details});

#################-Sub--Routines-#################

sub find_overlap{
	my $Ref_hp=shift;
	my $Pre_hp=shift;

	print "ref_gene\ttarget_seq\toverlap_num\tpre_gene\n";
	foreach  my $chr (sort keys %$Ref_hp) {

		my $output;
		my @ref_chr = (exists $Ref_hp->{$chr})  ? (sort {$a->[0] <=> $b->[0]} @{$Ref_hp->{$chr}}) : ();
		my @pre_chr = (exists $Pre_hp->{$chr})  ? (sort {$a->[0] <=> $b->[0]} @{$Pre_hp->{$chr}}) : ();

		print STDERR "find overlap on $chr\n" if(exists $opts{details});

		my $pre_pos = 0;
		for (my $i=0; $i<@ref_chr; $i++) {
			my $ref_gene = $ref_chr[$i][2];
			my @overlap;
			for (my $j=$pre_pos; $j<@pre_chr; $j++) {
				if ($pre_chr[$j][1] < $ref_chr[$i][0]) {
					$pre_pos++;
					next;
				}
				if ($pre_chr[$j][0] > $ref_chr[$i][1]) {
					last;
				}
				push @overlap,$pre_chr[$j][2];
			}
			$output .= $ref_gene."\t".$chr."\t".scalar(@overlap)."\t".join("\t",@overlap)."\n";
		}

		print $output;
	}

}




sub read_gff{
	my $file=shift;
	my $ref=shift;

	open (IN,$file) || die ("fail open $file\n");
	while (<IN>) {
		chomp;
		s/^\s+//;
		my @t = split(/\t/);
		my $tname = $t[0];

		my $qname;
		if ($t[2] eq 'mRNA' || $t[2] eq 'CDS') {
			$qname = $1 if($t[8] =~ /GenePrediction\s+(\S+)/ || $t[8] =~ /ID=([^;]+)/);
		}elsif ($t[2] eq 'CDS'){
			$qname = $1 if($t[8]=~/GenePrediction\s+(\S+)/ || $t[8] =~ /Parent=([^;]+)/);
		}
		if ($t[2] eq 'match' || $t[2] eq 'HSP') {
			$qname = $1 if($t[8] =~ /Target\s+\"(\S+)\"/);
		}

		if ($t[2] eq 'mRNA' || $t[2] eq 'match') {
			my $start = $t[3];
			my $end = $t[4];
			push @{$ref->{$tname}},[$start,$end,$qname];
		}
	}
	close(IN);

}

sub read_psl{
	my $file=shift;
	my $ref=shift;
	open(REF,$file)||die("fail to open $file\n");
	while (<REF>) {
		chomp;
		my @temp=split(/\s+/,$_);
		my $chr=$temp[13];
		$chr=~s/^[^_]+_//;
		my $gene=$temp[9];
		my $start=$temp[15]+1;
		my $end=$temp[16];

		push @{$ref->{$chr}},[$start,$end,$gene];
	}
	close(REF);
}
