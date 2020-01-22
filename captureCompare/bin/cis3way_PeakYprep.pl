#!/usr/bin/perl
use strict;
use Cwd;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long;


### (C) Damien Downes and James Davies 16th June 2018.


&GetOptions
(
    "viewpoints=s"=>\ my $vp_file,        # --viewpoints      VIEWPOINT	CHR VP_START VP_STOP EXCLSTART EXCLSTOP REGIONSTART REGIONSTOP BINSIZE WINDOWSIZE
	"samples=s"=> \ my $samples,		  # --samples		  Sample1,Sample2,Sample3
    "name=s"=> \my $run_name,             # --name             Name of the analysis
    "genome=s"=> \ my $genome,	    	  # --genome		  mm9/hg19
    "REfragments=s"=> \ my $frag_bed,	  # --REfragments	  /path/to/RE/fragment/coordinate/bed/file/eg/mm9_DpnII_Fragments.txt       # List of all RE fragments for genome as chr:start-stop, non-overlapping
);

my ($sampleA, $sampleB, $sampleC) = split /\,/, $samples;

## Generate a hash of all the fragments in the Genome with a unique ID
## Print the key for the fragments genome_DpnII_Fragments_key.bed
#chrom chromStart   chromEnd    ID
#chr1   10          200         1
#chr1   251         380         2

open(FRAGIN, "$frag_bed") or die "Can't open $frag_bed";

my $frag_key_out = "$genome\_DpnII_Fragments_key.bed";
open(KEYOUT, ">$frag_key_out") or die "Can't open $frag_key_out";
print KEYOUT "chrom\tchromStart\tchromEnd\tID\n";


my %FragIDHash;             #### Generate a hash of all of the DpnII fragments, each with a unique numeric ID
my $frag_counter;
while (my $frag = <FRAGIN>)
    { 
        chomp $frag;
        my ($chr,$start,$stop) = split(/[:-]/, $frag);
        my $hashchr = "chr$chr";
        $frag_counter ++;
        $FragIDHash{$hashchr}{$start}{$stop} = $frag_counter;                   #hash is in format: chr1 105  583  
        print KEYOUT "$chr\t$start\t$stop\t$frag_counter\n"    
    }
close KEYOUT;
close FRAGIN;


## Prepare output files

my $vpkey = "$run_name\_Viewpoint_key.tsv";
open(VPKEY, ">$vpkey") or die "Can't open $vpkey";   
print VPKEY "Name\tfragID\n";


my $sample1_out = "$sampleA\_counts.tsv";                   
my $sample2_out = "$sampleB\_counts.tsv";


open(SAMP1OUT, ">$sample1_out") or die "Can't open $sample1_out";
print SAMP1OUT "baitID\tpreyID\tN\n";
open(SAMP2OUT, ">$sample2_out") or die "Can't open $sample2_out";
print SAMP2OUT "baitID\tpreyID\tN\n";

if (length($sampleC) != 0)
    {
my $sample3_out = "$sampleC\_counts.tsv";
open(SAMP3OUT, ">$sample3_out") or die "Can't open $sample3_out";
print SAMP3OUT "BaitID\tPreyID\tN\n";
    }


my $error = "Unnassigned_viewpoint.tsv";
open(ERROR, ">$error") or die "Can't open $error";
print ERROR "Could not identify DpnII fragments for\n";
print ERROR "Name\tChr\tStart\tStop\n";

## Process samples

my $current_frag_ID;
open(VIEW_P, $vp_file) or die "Can't open $vp_file file";
while (my $target = <VIEW_P>)
    { 
        chomp $target;
        my ($viewID, $VP_chr, $VP_start, $VP_stop, @rest) = split(' ', $target);
        my $unionbdg = "$viewID\_raw.unionbdg";
        my $adj_start = $VP_start + 2;                          ### CCbasic uses ends of RE site eg ("|GATC----GATC|"), whereas peakY uses middle, "GA|TC----GA|TC")
        my $adj_stop = $VP_stop - 2;       
        if(exists $FragIDHash{$VP_chr}{$adj_start}{$adj_stop})
            {
                my $vp_fragID = $FragIDHash{$VP_chr}{$adj_start}{$adj_stop};                            ### Assign baits/vp the DpnII ID; Adjust ends to midpoint of DpnII
                print VPKEY "$viewID\t$vp_fragID\n";
                open(UNBEDGR, $unionbdg) or die "Can't open $unionbdg";
                while (my $ubg = <UNBEDGR>)
                    {
                          chomp $ubg;
                          my $s1_count =0;
                          my $s2_count =0;
                          my $s3_count =0;
                          my ($Chr,$Start,$Stop,$p1,$p2,$p3,$p4,$p5,$p6,$p7,$p8,$p9) = split(/\t/, $ubg);           ### Format is chr1
                          if ($Chr =~ /chrom/) {next;}
                          if(exists $FragIDHash{$Chr}{$Start}{$Stop})                                   
                            {
                                $current_frag_ID = $FragIDHash{$Chr}{$Start}{$Stop};                          
                                $s1_count = $p1+$p2+$p3;                                                ### PeakY takes the sum of raw replicates, in future hope to do replicates individually.
                                $s2_count = $p4+$p5+$p6;
                                if ($s1_count != 0)
                                  {print SAMP1OUT "$vp_fragID\t$current_frag_ID\t$s1_count\n";}
                                if ($s2_count != 0)
                                  {print SAMP2OUT "$vp_fragID\t$current_frag_ID\t$s2_count\n";}
                                if (length($sampleC) != 0)
                                  {
                                      $s3_count = $p7+$p8+$p9;
                                      if ($s3_count != 0)
                                        {print SAMP3OUT "$vp_fragID\t$current_frag_ID\t$s3_count\n";}
                                  }
                            }
                    }
                close UNBEDGR;
            }
        else{print ERROR "$viewID\t$VP_chr\t$adj_start\t$adj_stop\n" };
    }

close VIEW_P;
close SAMP1OUT;
close SAMP2OUT;
if (length($sampleC) != 0) {close SAMP3OUT;}
close VPKEY;
close ERROR;
exit;


