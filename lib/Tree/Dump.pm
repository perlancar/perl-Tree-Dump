package Tree::Dump;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Data::Dmp;
use Scalar::Util qw(blessed reftype);
use Tree::ToTextLines qw(render_tree_as_text);

use Exporter qw(import);
our @EXPORT = qw(td tdmp);

sub tdmp {
    my %opts = (
        show_guideline => 1,
        on_show_node => sub {
            my ($node, $level, $seniority, $is_last_child, $opts) = @_;
            my $res = "(".ref($node).") ";
            if (reftype($node) eq 'HASH') {
                $res .= dmp({
                    map { ($_ => $node->{$_}) }
                        grep { !/^_?children$/ && !blessed($node->{$_}) }
                            keys %$node });
            } else {
                $res .= dmp([ map { blessed($_) ? "<obj>": $_ } @$node]);
            }
            $res;
        },
    );

    render_tree_as_text(\%opts, $_[0]);
}

sub td {
    my $tdmp = tdmp(@_);
    print $tdmp;
    $tdmp;
}

1;
# ABSTRACT: Dump a tree object

=head1 SYNOPSIS

 use Tree::Dump; # exports td() and tdmp()
 td($tree);

Sample output:

 root
 |-- child1
 |   \-- grandc1
 |-- child2
 |-- child3
 |   |-- grandc2
 |   |-- grandc3
 |   |  |-- grandgrandc1
 |   |  \-- grandgrandc2
 |   |-- grandc4
 |   \-- grandc5
 \-- child4


=head1 DESCRIPTION

This module is useful for debugging. The interface is modeled after L<Data::Dmp>
(which in turn is modeled after L<Data::Dump>). Instead of C<dd>, this module
exports C<td> which you can use to dump a tree object to STDOUT. There is also
C<tdmp> (like Data::Dmp's C<dmp>) which return dumped data in a string.

Any tree object can be printed as long as it supports C<parent> and C<children>
methods. See L<Role::TinyCommons::Tree::Node> for more information about the
requirements.


=head1 FUNCTIONS

=head2 td($tree) => str

Dump tree to STDOUT and return it.

=head2 tdmp($tree) => str

Return dumped tree.


=head1 SEE ALSO

L<Tree::To::TextLines>
