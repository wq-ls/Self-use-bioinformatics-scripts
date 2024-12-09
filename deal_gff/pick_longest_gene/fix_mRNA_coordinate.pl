#!/usr/bin/perl

### By Sunshai (sunhai@genomic.cn)

use strict;
use warnings;

my ($gff, $out) = @ARGV;

open FL, $gff;
my %end;
while (<FL>) {
    chomp;
    my @tmp = split;
    
    if ($tmp[2] eq 'CDS') {
        my $id = $1 if ($tmp[8] =~ /Parent=([^;\s]+)/);
        #print "$id\n";
        if (!exists $end{$id}{'start'} or $tmp[3] <= $end{$id}{'start'}) {
            $end{$id}{'start'} = $tmp[3];
        }
        if (!exists $end{$id}{'end'} or $tmp[4] >= $end{$id}{'end'}) {
            $end{$id}{'end'} = $tmp[4];
        };
    };
};
close FL;

open FL, $gff;
open FLS, ">$out";
while (<FL>) {
    chomp;
    my @tmp = split;
    if ($tmp[2] eq 'mRNA') {
      my $id = $1 if ($tmp[8] =~ /ID=([^;\s]+)/);
        next if (!exists $end{$id}{'start'});
        $tmp[3] = $end{$id}{'start'};       
        $tmp[4] = $end{$id}{'end'};       
    };
    print FLS join("\t", @tmp), "\n";
};
close FLS;
close FL;
