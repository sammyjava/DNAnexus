#!/usr/bin/env perl

use strict;
use warnings;
use Carp;

use FindBin;
use lib ("$FindBin::RealBin/../../PerlLib");
use Fasta_reader;
use Nuc_translator;
use Getopt::Long qw(:config no_ignore_case bundling pass_through);
use Cwd;

my $usage = <<__EOUSAGE__;

##################################################################
#
# Required:
#
#  --transcripts <string>       file containing target transcripts in fasta format
#
# Optional:
#
#  --read_length <int>          default: 76
#
#  --frag_length <int>             default: 300
#
#  --out_prefix <string>        default: 'reads'
#
#  --depth_of_cov <int>         default: 100  (100x targeted base coverage)
#
#  --SS_lib_type <string>       RF or FR
#
#################################################################

__EOUSAGE__

    ;



my $require_proper_pairs_flag = 0;

my $transcripts;
my $read_length = 76;
my $spacing = 1;
my $frag_length = 300;
my $help_flag;
my $out_prefix = "reads";
my $depth_of_cov = 100;
my $SS_lib_type = "";

&GetOptions ( 'h' => \$help_flag,
              'transcripts=s' => \$transcripts,
              'read_length=i' => \$read_length,
              'frag_length=i' => \$frag_length,
              'out_prefix=s' => \$out_prefix,
              'depth_of_cov=i' => \$depth_of_cov,
              'SS_lib_type=s' => \$SS_lib_type,
              
    );


if (@ARGV) {
    die "Error, dont understand params: @ARGV";
}

if ($help_flag) {
    die $usage;
}

unless ($transcripts) { 
    die $usage;
}

unless ($out_prefix =~ /^\//) {
    $out_prefix = cwd() . "/$out_prefix";
}

main: {
    
    my $number_reads = &estimate_total_read_count($transcripts, $depth_of_cov, $read_length);
    
    my $cmd = "wgsim-trans -N $number_reads -1 $read_length -2 $read_length "
        . " -d $frag_length "
        . " -r 0 "
        . " -e 0 "
        ;

    my $token = "wgsim_R${read_length}_F${frag_length}_D${depth_of_cov}";
    
    if ($SS_lib_type) {

        $token .= "_${SS_lib_type}";
        
        if ($SS_lib_type eq 'FR') {
            $cmd .= " -Z 1 ";
        }
        elsif ($SS_lib_type eq 'RF') {
            $cmd .= " -Z 2 ";
        }
        else {
            die "Error, don't recognize SS_lib_type: [$SS_lib_type] ";
        }
    }

    my $left_prefix = "$out_prefix.$token.left";
    my $right_prefix = "$out_prefix.$token.right";
    
    $cmd .= " $transcripts $left_prefix.fq $right_prefix.fq";
    
    &process_cmd($cmd);

    # convert to fasta format
    &process_cmd("$FindBin::Bin/../support_scripts/fastQ_to_fastA.pl -I $left_prefix.fq > $left_prefix.fa");

    &process_cmd("$FindBin::Bin/../support_scripts/fastQ_to_fastA.pl -I $right_prefix.fq > $right_prefix.fa");

    unlink("$left_prefix.fq", "$right_prefix.fq");

    open(my $ofh, ">$out_prefix.$token.info") or die "Error, cannot write to file: $out_prefix.$token.info";
    print $ofh join("\t", $transcripts, "$left_prefix.fa", "$right_prefix.fa");
    close $ofh;
    
    
    exit(0);

}


####
sub estimate_total_read_count {
    my ($transcripts_fasta_file, $depth_of_cov, $read_length) = @_;

    my $sum_seq_length = 0;
    my $fasta_reader = new Fasta_reader($transcripts);
    while (my $seq_obj = $fasta_reader->next()) {
        my $sequence = $seq_obj->get_sequence();
        $sum_seq_length += length($sequence);
    }
    
    # DOC = num_reads * read_length * 2 / seq_length

    # so, 

    # num_reads = DOC * seq_length / 2 / read_length

    my $num_reads = $depth_of_cov * $sum_seq_length / 2 / $read_length;

    $num_reads = int($num_reads + 0.5);
    
    return($num_reads);
}


####
sub process_cmd {
    my ($cmd) = @_;

    print STDERR "CMD: $cmd\n";

    my $ret = system($cmd);

    if ($ret) {
        die "Error, cmd: $cmd died with ret $ret";
    }

    return;
}

