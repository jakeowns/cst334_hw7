#!/usr/bin/perl
use feature qw(say);
use List::Util qw(first);
use constant {
  EMPTY_PAGE => -1,
  FRAMES     => 4
};

# Set up array for Global Variables
my ( $ref_str, $count ) = ( get_refs("/home/cst334/HW7/data.txt"), {} );

# get_refs()
# open files and parse number
# return: array of numbers
sub get_refs {
  open my $fh, '<', $_[0] or die("Error opening file.");
  chomp( my $file = <$fh> ); # remove newline at EOL and store to $file
  close $fh;
  return [ split ',', $file ];
}

# first_occur()
# find the first occurance
# return: first time number appears
sub first_occur {
  my ( $val, $ref, $start ) = @_;
  return first { $ref->[$_] eq $val } ( $start || 0 ) .. $#{$ref};
}

# print_frame()
# display current action, frame layout and number
sub print_frame {
  my ( $p, $action, $ref_val ) = (@_);
  say $action . ' ' . $ref_val; # Example: [hit, miss, vicitim] number
  for ( @{$p} ) {
    $_ = ' ' if $_ eq EMPTY_PAGE;
    say '|' . $_ . '|'; # Example: |number|
  }
  count_actions($action);
}

# count_actions()
# increament the type of action
sub count_actions {
  $count->{ $_[0] }++ if defined $_[0];
}

# optimal()
# optimal algorithm
sub optimal {
  my ( $index, $pages, $ref ) = (@_);
  my ( $ref_val, $action ) = ( $ref->[$index], '' );
  my @p = @{$pages};    # save page
  if ( grep { $_ eq $ref_val } @{$pages} ) {
    # hit
    $action = "hit";
  }
  else {
    # miss
    my $empty = first_occur( EMPTY_PAGE, $pages );
    $action = "miss";
    if ( defined $empty ) {
      $pages->[$empty] = $ref_val;
    }
    else {
      # find replacement
      print_frame( \@p, $action, $ref_val );
      my ( $furthest, $val, $victim ) = ( $pages->[0], $ref_val, 0 );
      for ( @{$pages} ) {
        my $first = first_occur( $_, $ref, $index );
        if ( ( not defined $first ) || $first > $furthest ) {
          $furthest = $first;
          last unless defined $first;
        }
      }
      # process victim
      $action           = "victim";
      $victim           = first_occur( $ref->[$furthest], $pages );
      $ref_val          = $pages->[$victim];
      $pages->[$victim] = $val;
    }
  }
  print_frame( \@p, $action, $ref_val );
}

# main
sub run {
  my ( $ref_list, @pages ) = ( @_, (EMPTY_PAGE) x FRAMES );
  for my $index ( 0 .. $#{$ref_list} ) {
    optimal( $index, \@pages, $ref_list );
  }
  say "Total hits: $count->{hit}\n"
    . "Total miss: $count->{miss}";
}

# Start the script
run($ref_str);
