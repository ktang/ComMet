#!/usr/bin/perl

# Bisulfighter http://epigenome.cbrc.jp/bisulfighter
# by National Institute of Advanced Industrial Science and Technology (AIST)
# is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
# http://creativecommons.org/licenses/by-nc-sa/3.0/

use strict;
use warnings;

# pool multiple bsf-call outputs to a single bsf-call output
#
# usage:
# ./this_program BsfOutput1.tsv BsfOutput2.tsv BsfOutput3.tsv ...

my $infile = join(" ", @ARGV);

my ($nm, $pos, $str, $cxt, $r, $d) = ("NA", -1, "NA", "NA", -1, -1);
my $init = 1;

open(IN, "cat $infile | sort -k1,1 -k2,2n -k3,3 -k4,4 | ") or die "couldn't open input file $infile\n";
while (my $line=<IN>) {
    chomp $line;
    my @cells = split(/\s+/, $line);

    if ($nm eq $cells[0] && $pos == $cells[1]) {
        $str eq $cells[2] or die "mC at the same position in different strands, $str, $line\n";
        if ($cxt eq $cells[3]) {
	    if ($d + $cells[5] == 0) {
		$r = 0;
		$d = 0;
	    }
	    else {
		$r = ($r*$d + $cells[4]*$cells[5]) / ($d + $cells[5]);
		$d = $d + $cells[5];
	    }
	    next;
        }
    }
    if ($init) {
        $init = 0;
    }
    else {
	$d==0 and print STDERR "warning: mC with depth==0 at $nm, $pos, $str\n"; 
        print join("\t", ($nm, $pos, $str, $cxt, $r, $d)), "\n";
    }

    ($nm, $pos, $str, $cxt, $r, $d) = (@cells);
}
$d==0 and print STDERR "warning: mC with depth==0 at $nm, $pos, $str\n"; 
print join("\t", ($nm, $pos, $str, $cxt, $r, $d)), "\n";
