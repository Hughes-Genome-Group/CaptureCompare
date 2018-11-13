#!/usr/bin/perl -w
use strict;
use Cwd;
use Data::Dumper;
use Getopt::Long;
use Try::Tiny;

### This is a sub script for CC4 triplicate analysis which generates union bedgraphs for all oligos from 3 test and 3 control samples

### (C) Damien Downes 16th May 2018.


&GetOptions
(
    "dir=s"=> \my @dirs,                # -dir          The directories that contain the gff files for all the samples (subdirectories) that you want to analyse,
                                        #               separated by only a comma (no space); these subdirectories need to contain the gff files, so it will be the ‘F6’
                                        #               folder generated by CC4; you don’t have to give the full path to these folders, just direct down from the path
                                        #               you’ve entered (it will be two directories down)
    "viewpoints=s" => \my $vp_file,     # -viewpoints   VIEWPOINT	CHR VP_START VP_STOP EXCLSTART EXCLSTOP REGIONSTART REGIONSTOP BINSIZE WINDOWSIZE
                                        #               Note: chr is numeric  (1 NOT chr1)
    "samples=s"=> \ my $samples,		# -samples		Sample1,Sample2,Sample3
);


my ($sampleA, $sampleB, $sampleC) = split /\,/, $samples;
 
my $s1_r1;
my $s1_r2;
my $s1_r3;
my $s2_r1;
my $s2_r2;
my $s2_r3;
my $s3_r1;
my $s3_r2;
my $s3_r3;

if (length($sampleC) == 0)
    {
    ($s1_r1,$s1_r2,$s1_r3,$s2_r1,$s2_r2,$s2_r3) = split(/,/,join(',',@dirs));
    }
if (length($sampleC) != 0)
    {
    ($s1_r1,$s1_r2,$s1_r3,$s2_r1,$s2_r2,$s2_r3,$s3_r1,$s3_r2,$s3_r3) = split(/,/,join(',',@dirs));
    }

my $bedtools_command = "bedtools_commands_TEMP.txt";
open(BED, ">$bedtools_command") or die "Can't open $bedtools_command file";
open(VP, $vp_file) or die "Can't open $vp_file file";
while (my $target = <VP>)
        { 
        chomp $target;
        my ($vp, @rest) = split(' ', $target);
              
        my $file1 = "$s1_r1\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
        my $file2 = "$s1_r2\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
        my $file3 = "$s1_r3\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
        my $file4 = "$s2_r1\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
        my $file5 = "$s2_r2\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
        my $file6 = "$s2_r3\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
        if (length($sampleC) == 0)
            {
                print BED "bedtools unionbedg -i $file1 $file2 $file3 $file4 $file5 $file6  > $vp\_normalised.unionbdg\n";
            }        
        if (length($sampleC) != 0)
            {        
        my $file7 = "$s3_r1\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
        my $file8 = "$s3_r2\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
        my $file9 = "$s3_r3\_$vp\_cis_normalised_sorted_TEMP.bedgraph";
                print BED "bedtools unionbedg -i $file1 $file2 $file3 $file4 $file5 $file6 $file7 $file8 $file9  > $vp\_normalised.unionbdg\n";
            }   

        $file1 = "$s1_r1\_$vp\_sorted_TEMP_raw.bedgraph";
        $file2 = "$s1_r2\_$vp\_sorted_TEMP_raw.bedgraph";
        $file3 = "$s1_r3\_$vp\_sorted_TEMP_raw.bedgraph";
        $file4 = "$s2_r1\_$vp\_sorted_TEMP_raw.bedgraph";
        $file5 = "$s2_r2\_$vp\_sorted_TEMP_raw.bedgraph";
        $file6 = "$s2_r3\_$vp\_sorted_TEMP_raw.bedgraph";
        if (length($sampleC) == 0)
            {
                print BED "bedtools unionbedg -i $file1 $file2 $file3 $file4 $file5 $file6 -header -names $s1_r1 $s1_r2 $s1_r3 $s2_r1 $s2_r2 $s2_r3  > $vp\_raw.unionbdg\n";
            }
        if (length($sampleC) != 0)
            {
        my $file7 = "$s3_r1\_$vp\_sorted_TEMP_raw.bedgraph";
        my $file8 = "$s3_r2\_$vp\_sorted_TEMP_raw.bedgraph";
        my $file9 = "$s3_r3\_$vp\_sorted_TEMP_raw.bedgraph";
                print BED "bedtools unionbedg -i $file1 $file2 $file3 $file4 $file5 $file6 $file7 $file8 $file9 -header -names $s1_r1 $s1_r2 $s1_r3 $s2_r1 $s2_r2 $s2_r3 $s3_r1 $s3_r2 $s3_r3 > $vp\_raw.unionbdg\n";
            }
        }

close VP;
close BED;

exit;