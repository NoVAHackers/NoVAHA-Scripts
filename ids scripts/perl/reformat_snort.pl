#!/usr/bin/perl
# vim: filetype=perl foldmethod=marker commentstring=\ #\ %s

# Usage:
# perl reformat_snort.pl < gnarly_rules.rules > beautified_rules.rules
# 
# Description:
# Reposition elements in snort rules to make them easier to read, and increments the signature revision.
# 
# Adjust the @prefix and @postfix lines below w/ the elements you want moved around.
#
# Author: Richard Harman <richard@richardharman.com>

use strict;
use warnings;
use Parse::Snort;
use List::MoreUtils qw(firstidx);

my $parser = new Parse::Snort;

# snort rule elements to go at the beginning of a rule
my @prefix = qw(msg);
# snort rule elements to go at the end of a rule
my @postfix = qw(classtype gid sid rev);

while (<>) {
  chomp;
  $parser->parse($_);
  my $opts = $parser->opts();
  my ($pre_options,$post_options);
  
  # pull out prefix elements
  foreach my $pre (@prefix) { # {{{
    my $index = firstidx { lc($_->[0]) eq lc($pre) } @$opts;
    next if ($index == -1);
    push @$pre_options, splice (@$opts,$index,1);
  }  # }}}
  
  # pull out postfix elements
  foreach my $post (@postfix) { # {{{
    my $index = firstidx { lc($_->[0]) eq lc($post) } @$opts;
    next if ($index == -1); 
    push @$post_options, splice (@$opts,$index,1);
  } # }}}

  # increment revision;
  my $rev_idx = firstidx { lc($_->[0]) eq "rev"} @$post_options;
  $post_options->[$rev_idx]->[1]++;
  
  my @rebuilt = (@$pre_options, @$opts, @$post_options);
  $parser->opts(\@rebuilt);
  print $parser->as_string,"\n";
}
