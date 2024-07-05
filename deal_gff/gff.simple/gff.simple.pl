#!/usr/bin/perl -w
## gff.simple.pl -gff in.gff > out.gff
use strict;
use Getopt::Long;
my ($infile,$tag,$mrna);
GetOptions(
	"gff:s"=>\$infile,
	"tag:s"=>\$tag,
	"mrna:s"=>\$mrna
	);
$tag ||= 'ID';
$mrna ||='CDS';
my %CDS;
my %gid;
open IN, "$infile" || die "$!\n";
while(<IN>){
	chomp;
	next if (/^#/);
	next if (/^\s*$/);
	my @info=split(/\s+/, $_);
	if ($info[2]=~/$mrna/){
		if ($info[8]=~/$tag=([^;]+)/){
#			if ($info[9]=~/\"(\S+?)\";/){
			#if (exists $gid{$1}){
			#	next;
			#}else{
			#	$gid{$1}++;
			#}
			my $key=$1;
			($info[3],$info[4])=($info[4],$info[3]) if ($info[3]>$info[4]);
#			push @{$CDS{$key}}, [@info];
			push @{$CDS{$key}}, [$info[0],$info[1],$info[2],$info[3],$info[4],$info[5],$info[6],$info[7],$info[9]];
		}
	}
}
close IN;

foreach my $id (sort keys %CDS){
#	@{$CDS{$id}}=sort {$a->[3] <=> $b->[3]} @{$CDS{$id}};
#	my $ms=$CDS{$id}[0][3];
#	my $me=$CDS{$id}[-1][4];
#	my $strand =$CDS{$id}[0][6];
#	print "$CDS{$id}[0][0]\t$CDS{$id}[0][1]\tmRNA\t$ms\t$me\t\.\t$strand\t\.\tID=$id;\n";
	my $newc='';
	if ($CDS{$id}[0][6] eq '+'){
		@{$CDS{$id}}=sort {$a->[3] <=> $b->[3]} @{$CDS{$id}};
		#$CDS{$id}[-1][4] +=3;
		print "$CDS{$id}[0][0]\t$CDS{$id}[0][1]\tmRNA\t$CDS{$id}[0][3]\t $CDS{$id}[-1][4]\t\.\t$CDS{$id}[0][6]\t\.\tID=$id;\n";
		for (my $i=0; $i<@{$CDS{$id}}; $i++){
			$CDS{$id}[$i][8]="Parent=$id;";
			$newc=join "\t", @{$CDS{$id}[$i]};
			print "$newc\n";
		}
	}
	if ($CDS{$id}[0][6] eq '-'){
		@{$CDS{$id}}=reverse (sort {$a->[3] <=> $b->[3]} @{$CDS{$id}});
		#$CDS{$id}[-1][3] -=3;
		print "$CDS{$id}[0][0]\t$CDS{$id}[0][1]\tmRNA\t$CDS{$id}[-1][3]\t $CDS{$id}[0][4]\t\.\t$CDS{$id}[0][6]\t\.\tID=$id;\n";
		for (my $i=0; $i<@{$CDS{$id}}; $i++){
			$CDS{$id}[$i][8]="Parent=$id;";
			$newc=join "\t", @{$CDS{$id}[$i]};
			print "$newc\n";
		}
	}
}
