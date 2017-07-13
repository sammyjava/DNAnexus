#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib ("$FindBin::RealBin/../../PerlLib");
use Fasta_reader;

my $usage = "usage: $0 EXPR.matrix Trinity.fasta\n\n";


my $matrix_file = $ARGV[0] or die $usage;
my $fasta_file = $ARGV[1] or die $usage;

my %trans_lengths;
{
    my $fasta_reader = new Fasta_reader($fasta_file);
    while (my $seq_obj = $fasta_reader->next()) {
        
        my $acc = $seq_obj->get_accession();
        my $sequence = $seq_obj->get_sequence();
        
        my $seq_len = length($sequence);

        $trans_lengths{$acc} = $seq_len;
    }
}

open (my $fh, $matrix_file) or die $!;
my $header = <$fh>;

my @trans;

my $sum_expr = 0;

while (<$fh>) {
    chomp;
    my @x = split(/\t/);
    my $acc = shift @x; # gene accession
    my $max_expr = 0;
    my $trans_sum_expr = 0;
    while (@x) {
        my $expr = shift @x;
        
        $trans_sum_expr += $expr;
        $sum_expr += $expr;    

        if ($expr > $max_expr) {
            $max_expr = $expr;
        }
    }
    
    my $seq_len = $trans_lengths{$acc} or die "Error, no seq length for acc: $acc";
    
    push (@trans, { acc => $acc,
                    len => $seq_len,
                    sum_expr => $trans_sum_expr,
                    max_expr => $max_expr,
                });
    
}

@trans = reverse sort { $a->{sum_expr} <=> $b->{sum_expr}
                        ||
                            $a->{len} <=> $b->{len} } @trans;


## write output table
{
    open (my $ofh, ">$matrix_file.E-inputs") or die $!;
    print $ofh join("\t", "#acc", "length", "max_expr_over_samples", "sum_expr_over_samples") . "\n";
    foreach my $t (@trans) {
        print $ofh join("\t", $t->{acc}, $t->{len}, $t->{max_expr}, $t->{sum_expr}) . "\n";
    }
    close $ofh;
}


my %Estats_wanted = map { $_ => 1 } (1..100);



print "#E\tmin_expr\tE-N50\tnum_transcripts\n";

my $sum = 0;
my @captured;
while (@trans) {
    
    my $t = shift @trans;
    push (@captured, $t);

    $sum += $t->{sum_expr};

    my $pct = int($sum/$sum_expr * 100);
    
    if ($Estats_wanted{$pct}) {
        
        my $min_max_expr = &get_min_max(@captured);
        
        delete($Estats_wanted{$pct});

        my $N50 = &calc_N50(@captured);
        my $num_trans = scalar(@captured);
        
        print "E$pct\t$min_max_expr\t$N50\t$num_trans\n";
    }
}

# ensure that we do E100
if (%Estats_wanted) {
    
    if (exists $Estats_wanted{"100"}) {
        my $min_max_expr = &get_min_max(@captured);
        my $N50 = &calc_N50(@captured);
        my $num_trans = scalar(@captured);
        
        print "E100\t$min_max_expr\t$N50\t$num_trans\n";
    }
}

exit(0);


####
sub get_min_max {
    my @entries = @_;
    
    my $min = $entries[0]->{max_expr};
    foreach my $entry (@entries) {
        if ($entry->{max_expr} < $min) {
            $min = $entry->{max_expr};
        }
    }

    return($min);
}


####
sub calc_N50 {
    my @entries = @_;
    
    @entries = reverse sort {$a->{len}<=>$b->{len}} @entries;
    
    my $sum_len = 0;
    foreach my $entry (@entries) {
        $sum_len += $entry->{len};
    }

    my $loc_sum = 0;
    foreach my $entry (@entries) {
        $loc_sum += $entry->{len};
        if ($loc_sum / $sum_len * 100 >= 50) {
            return($entry->{len});
        }
    }

    return(-1); # error
}

