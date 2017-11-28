#!/usr/bin/perl
use warnings;
use strict  ;

my $sum = 0;
my $n   = 0;


while(<STDIN>){
    chomp;
    my @l = split /\t/, $_;
    $sum += $l[4];
    $n++;
}

my $mean = $sum / $n;

print STDERR "sum\t$sum\n";
print STDERR "n\t$n\n";

print $mean;
