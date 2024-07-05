#!/usr/bin/perl -w
use strict;
@ARGV||die "Usage: perl $0 <gff> <name> > rename.gff\n";
my ($file,$name)=@ARGV;
open IN,shift;
my $num='00000';
while(<IN>){
	chomp;
	my @a=split;
	if($a[2] eq "mRNA"){
	$num++;
	$a[8]="ID=$name$num;";
	print join "\t",@a;print "\n";
	}
	else{
	$a[8]="Parent=$name$num;";
	print join "\t",@a;print "\n";
	}
}
close IN;
