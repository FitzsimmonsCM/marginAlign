#! /usr/bin/perl -w
use strict;

die "must provide two kmer files to compare\nusage: cmpKmer.pl <refKmerFile> <readKmerFile> <output>\nK-mer file format must be generated by or match the output from kmer.pl program\n" unless($ARGV[0]);
die "must provide two kmer files to compare\nusage: cmpKmer.pl <refKmerFile> <readKmerFile> <output> \nK-mer file format  must be generated by or match the output from kmer.pl program\n" unless($ARGV[1]);
die "must provide output file\nusage: cmpKmer.pl <refKmerFile> <readKmerFile> <output> \nK-mer file format  must be generated by or match the output from kmer.pl program\n" unless($ARGV[2]);



open(REF,"$ARGV[0]");

my $countRef=0;
my %kmerRef;

while(<REF>){
    chomp;
    my @l=split(/\t+/,$_);
    my $lN=@l;
    if($lN < 4){
	die "file: $ARGV[0]\nLINE: $_\n format incorrect\n";
    }
    $countRef+=2;
    $kmerRef{$l[2]}=1 unless($kmerRef{$l[2]}++);
    $kmerRef{$l[3]}=1 unless($kmerRef{$l[3]}++);
}
close REF;

open(RDS,"$ARGV[1]");
my $countRds=0;
my $countNoGap=0;
my %kmerRds;
while(<RDS>){
    chomp;
    my @l=split(/\t+/,$_);
    my $lN=@l;
    if($lN < 4){
	die "file: $ARGV[1]\nLINE: $_\n format incorrect\n";
    }
    $countRds+=2;
    if($l[2]!~ /\-/){
	$countNoGap++;
	$kmerRds{$l[2]}=1 unless($kmerRds{$l[2]}++);
    }
    if($l[3]!~ /\-/){
	$countNoGap++;
	$kmerRds{$l[3]}=1 unless($kmerRds{$l[3]}++);
    }
}
close RDS;
open(OUT,">$ARGV[2]");
foreach my $kRef(keys %kmerRef){
    my $refFreq=$kmerRef{$kRef}/$countRef;
    if(exists $kmerRds{$kRef}){
	my $rdsFreq=$kmerRds{$kRef}/$countNoGap;
	my $totFreq=$kmerRds{$kRef}/$countRds;
	my $ratio1=log($rdsFreq/$refFreq);
	my $ratio2=log($totFreq/$refFreq);
	print OUT "$kRef\t$kmerRef{$kRef}\t$refFreq\t$kmerRds{$kRef}\t$rdsFreq\t$ratio1\t$totFreq\t$ratio2\n";
    }
    else{
	print OUT "$kRef\t$kmerRef{$kRef}\t$refFreq\t0\t0\t0\t0\t0\n";
    }
}
close OUT;
