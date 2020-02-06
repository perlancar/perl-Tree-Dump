## no critic: Modules::ProhibitAutomaticExportation

package Tree::Dump;

# AUTHORITY
# DATE
# DIST
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
    my %opts;

    if (ref($_[0]) eq 'HASH') {
        %opts = %{shift @_};
    }

    $opts{show_guideline} = 1;
    $opts{on_show_node} = sub {
        my ($node, $level, $seniority, $is_last_child, $opts) = @_;
        die "Please specify tree node object (arg0)" unless defined $node;
        my $res = "(".ref($node).") ";
        if (reftype($node) eq 'HASH') {
            $res .= dmp({
                map { ($_ => $node->{$_}) }
                    grep { !/^_?children$/ && !blessed($node->{$_}) }
                    keys %$node });
        } elsif (reftype($node) eq 'ARRAY') {
            $res .= dmp([ map { blessed($_) ? "<obj>": $_ } @$node]);
        } else {
            $res .= "$node";
        }
        $res;
    };

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

 (Tree::Example::HashNode) {_parent=>undef,id=>1,level=>0}
 |-- (Tree::Example::HashNode::Sub1) {id=>2,level=>1}
 |   \-- (Tree::Example::HashNode::Sub2) {id=>5,level=>2}
 |       |-- (Tree::Example::HashNode::Sub1) {id=>7,level=>3}
 |       |   \-- (Tree::Example::HashNode::Sub2) {id=>15,level=>4}
 |       |-- (Tree::Example::HashNode::Sub1) {id=>8,level=>3}
 |       |-- (Tree::Example::HashNode::Sub1) {id=>9,level=>3}
 |       \-- (Tree::Example::HashNode::Sub1) {id=>10,level=>3}
 |-- (Tree::Example::HashNode::Sub1) {id=>3,level=>1}
 |   \-- (Tree::Example::HashNode::Sub2) {id=>6,level=>2}
 |       |-- (Tree::Example::HashNode::Sub1) {id=>11,level=>3}
 |       |   \-- (Tree::Example::HashNode::Sub2) {id=>16,level=>4}
 |       |-- (Tree::Example::HashNode::Sub1) {id=>12,level=>3}
 |       |-- (Tree::Example::HashNode::Sub1) {id=>13,level=>3}
 |       \-- (Tree::Example::HashNode::Sub1) {id=>14,level=>3}
 \-- (Tree::Example::HashNode::Sub1) {id=>4,level=>1}

Sample output when rendering an array-backed tree:

 (Tree::Example::ArrayNode) [undef,undef,undef,"<obj>","<obj>","<obj>"]
 |-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>","<obj>"]
 |   \-- (Tree::Example::ArrayNode::Sub2) [undef,undef,"<obj>","<obj>","<obj>","<obj>","<obj>"]
 |       |-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>","<obj>"]
 |       |   \-- (Tree::Example::ArrayNode::Sub2) [undef,undef,"<obj>"]
 |       |-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>"]
 |       |-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>"]
 |       \-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>"]
 |-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>","<obj>"]
 |   \-- (Tree::Example::ArrayNode::Sub2) [undef,undef,"<obj>","<obj>","<obj>","<obj>","<obj>"]
 |       |-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>","<obj>"]
 |       |   \-- (Tree::Example::ArrayNode::Sub2) [undef,undef,"<obj>"]
 |       |-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>"]
 |       |-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>"]
 |       \-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>"]
 \-- (Tree::Example::ArrayNode::Sub1) [undef,undef,"<obj>"]


=head1 DESCRIPTION

This module is useful for debugging. The interface is modeled after L<Data::Dmp>
(which in turn is modeled after L<Data::Dump>). Instead of C<dd>, this module
exports C<td> which you can use to dump a tree object to STDOUT. There is also
C<tdmp> (like Data::Dmp's C<dmp>) which return dumped data in a string.

Any tree object can be printed as long as it supports C<parent> and C<children>
methods. See L<Role::TinyCommons::Tree::Node> for more information about the
requirements.


=head1 FUNCTIONS

=head2 td([ \%opts, ] $tree) => str

Dump tree to STDOUT and return it. See C<tdmp> for list of known options.

=head2 tdmp([ \%opts, ] $tree) => str

Return dumped tree. If first argument is a plain hashref, it will be regarded as
options. Known options:

=over

=item * get_children_method => str (default: children)

Example:

 get_children_method => "get_children"

By default, C<children> is the method that will be used on node objects to
retrieve children nodes. But you can customize that using this option. Note that
the method must return either a list or arrayref of nodes.

=item * indent => int (default: 2)

Number of spaces for each indent level.

=back


=head1 SEE ALSO

L<Tree::To::TextLines>
