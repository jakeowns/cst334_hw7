#!/usr/bin/perl
use feature qw(say);
use List::Util qw(first);
my @refs  = get_refs("/home/cst334/HW7/data.txt");
my %count = {};

sub get_refs {
  my $file;
  open my $fh, '<', $_[0] or die;
  $file = <$fh>;
  chomp $file;
  close $fh;
  return split ',', $file;
}

sub print_frame {
  my ( $p, $action, $ref_val ) = (@_);
  say $action . ' ' . $ref_val;
  for ( @{$p} ) {
    if ( $_ eq -1 ) { $_ = ' '; }
    say '|' . $_ . '|';
  }
}

sub optimal {
  my ( $page, $index, $ref ) = (@_);
  my ( $v, $action ) = ( $ref->[$index], '' );
  my @p = @{$page};    # save page
  if ( grep { $_ eq $v } @{$page} ) {
    # hit
    $action = "hit";
    $count{'hit'}++;
  }
  else {
    my $i = first { $page->[$_] eq -1 } 0 .. $#{$page};
    $action = "miss";
    $count{'miss'}++;
    if ( defined $i ) {
      # miss?
      $page->[$i] = $v;
    }
    else {
      # find replacement
      print_frame( \@p, $action, $v );
      my ( $max, $victim_index, $val ) = ( $page->[0], 0, $v );
      for my $val ( @{$page} ) {
        my $first = first { $ref->[$_] eq $val } $index .. $#{$ref};
        if ( $first == -1 || $first > $max ) {
          $max = $first;
          if ( $first == -1 ) {
            last;
          }
        }
      }
      $action       = "victim";
      $victim_index = first { $page->[$_] eq $ref->[$max] } 0 .. $#{$page};
      $v            = $page->[$victim_index];
      $page->[$victim_index] = $val;
    }
  }
  print_frame( \@p, $action, $v );
}

# main
sub run {
  my ( $ref_list, $frames ) = @_;
  my @pages = (-1) x $frames;
  for ( 0 .. $#{$ref_list} ) {
    optimal( \@pages, $_, $ref_list );
  }
  say "Total hits: $count{hit}\nTotal miss: $count{miss}";
}
run( \@refs, 4 );
