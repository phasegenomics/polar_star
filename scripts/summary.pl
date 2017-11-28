#!/usr/bin/perl
use warnings;
use strict  ;

my $low      = 0;
my $normal   = 0;
my $high     = 0;
my $total    = 0;

while(<STDIN>){
    chomp;
    my @l = split /\t/, $_;
    my $len = $l[2] - $l[1];
    $low    += $len if($_ =~ /_ld/) ;
    $normal += $len if($_ =~ /_nd/) ;
    $high   += $len if($_ =~ /_hd/) ;
    $total  += $len; 

    print STDERR "$l[3]," if($_ !~ /_nd/);

}

my $phi = ($high / $total)   * 100;
my $plo = ($low  / $total)   * 100;
my $pno = ($normal / $total) * 100;

print "#name\tpercent\tbases\n";
print "hi\t$phi\t$high\n";
print "low\t$plo\t$low\n";
print "normal\t$pno\t$normal\n";
