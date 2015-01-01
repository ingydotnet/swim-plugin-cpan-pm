use strict; use warnings;
package Swim::Plugin::cpan;
our $VERSION = '0.0.2';

package Swim::Pod;

sub block_func_cpan_head {
    my ($self, $args) = @_;
    my $meta = $self->meta;
    my $head_name = $self->option->{'pod-upper-head'} ? 'NAME' : 'Name';
    (my $name = $meta->{name}) =~ s/-/::/g;
    my $out = <<"...";
=head1 $head_name

$name - $meta->{abstract}
...
    while (1) {
        my $badge = $self->{meta}{badge} or last;
        $badge = [$badge] unless ref $badge;
        my $repo = $meta->{devel}{git} or last;
        $repo =~ s!.*[:/]([^/]+)/([^/]+?)(?:\.git)?$!$1/$2!
            or last;
        eval "require Swim::Plugin::badge; 1" or last;
        $out .= "\n" . $self->phrase_func_badge("@$badge $repo");
        chomp $out;
        last;
    }
    return $out;
}

sub block_func_cpan_tail {
    my ($self, $args) = @_;
    my $meta = $self->meta;
    my $out = '';
    my ($head_see, $head_author, $head_copyright) = map {
        $self->option->{'pod-upper-head'} ? uc($_) : $_
    } (
        'See Also',
        'Author',
        'Copyright and License',
    );
    if (my $see = $meta->{see}) {
        $out .= "=head1 $head_see\n\n=over\n\n";
        $see = [$see] unless ref $see;
        for (@$see) {
            $out .= "=item * L<$_>\n\n";
        }
        $out .= "=back\n\n";
    }
    return $out . <<"...";
=head1 $head_author

$meta->{author}{name} <$meta->{author}{email}>

=head1 $head_copyright

Copyright $meta->{copyright}. $meta->{author}{name}.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>
...
}

1;
