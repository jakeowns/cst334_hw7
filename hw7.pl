#!/usr/bin/perl
use feature qw(say);
use List::Util qw(first);
my @ref_list;
my $frames = 4;
my @page   = (-1) x $frames;
my %count  = {};

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
  my ( $index, $v ) = (@_);
  my ( $action, $ref );
  my @p = @page;    # save page
  if ( grep { $_ eq $v } @page ) {
    # hit
    $action = "hit";
    $count{'hit'}++;
  }
  else {
    my $i = first { $page[$_] eq -1 } 0 .. $#page;
    $action = "miss";
    $count{'miss'}++;
    if ( defined $i ) {
      # miss?
      $page[$i] = $v;
    }
    else {
      # find replacement
      my $max  = $page[0];
      my $orig = $v;
      print_frame( \@p, $action, $v );
      for my $val (@page) {
        my $first = first { $ref_list[$_] eq $val } $index .. $#ref_list;
        if ( $first == -1 ) {
          $max = $first;
          last;
        }
        elsif ( $first > $max ) {
          $max = $first;
        }
      }
      $action = "victim";
      $v      = $ref_list[$max];
      my $ii = first { $page[$_] eq $v } 0 .. $#page;
      $page[$ii] = $orig;
    }
  }
  print_frame( \@p, $action, $v );
}

# main
@ref_list = get_refs("/home/cst334/HW7/data.txt");
for ( 0 .. $#ref_list ) {
  optimal( $_, $ref_list[$_] );
}
say "Total hits: $count{hit}\nTotal miss: $count{miss}";
