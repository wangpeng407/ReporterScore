#!/usr/bin/perl -w 
use strict;
use warnings;

@ARGV == 2 || die "perl $0 pathway-KO.list pathway.desc.list > path_stat_KO.v2.xls\n";
my ($rlist, $desc) = @ARGV;

my %ID2KOs;

open IN, $rlist || die $!;
while(<IN>){
	chomp;
	my ($KO, $ID) = split /\t/;
	push @{$ID2KOs{$ID}}, $KO;
}
close IN;

print "id\tK_num\tKOs\tDescription\n";
open DESC, $desc || die $!;
while(<DESC>){
	chomp;
	my ($ID, $detail) = split /\t/;
	$ID2KOs{$ID} || warn "No KOs in $ID\n";
	$ID2KOs{$ID} || next;
	print "$ID\t", scalar(@{$ID2KOs{$ID}}), "\t", join(",", @{$ID2KOs{$ID}}), "\t", $detail, "\n";
}
close DESC;
