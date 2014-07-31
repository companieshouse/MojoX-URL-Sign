package MojoX::URL::Sign::Plugin;

use Mojo::Base 'Mojolicious::Plugin';

use MojoX::URL::Sign;

sub register {
    my $self = shift;
    my $app  = shift;
    my $arg  = ref($_[0]) eq 'HASH' ? shift : {@_};

    die('No salt supplied') unless (defined($arg->{salt}));

    $app->helper(sign_url   => sub { my $self = shift; return MojoX::URL::Sign->sign_url(shift // $self->req->url->to_abs, $arg->{salt}); });
    $app->helper(verify_url => sub { my $self = shift; return MojoX::URL::Sign->verify_url(shift // $self->req->url->to_abs, $arg->{salt}); });

    return;
}

1;

=encoding utf8

=head1 NAME

MojoX::URL::Sign::Plugin - <Mojolicious> plugin for L<MojoX::URL::Sign>

=head1 SYNOPSIS

    # Somewhere inside your L<Mojolicious> app C<startup>...
    $self->plugin('MojoX::URL::Sign::Plugin', salt => 'secret-salt'); # Only need to pass the salt here
    
    # Somewhere inside your L<Mojolicious> controller...
    my $signed_url = $self->sign_url('http://example.com/some_page?for=bar');
    # (Defaults to current page if no URL arg passed in)
    $self->render(text => "The signed URL is $signed_url");

    # ...or inside your template...
    <a href="<% $c.sign_url($c.url_for('some_page', foo => $bar).to_abs) %>">My link</a>

    # Then in the "some_page" action...
    my $verified_url = $self->verify_url; # verifies the current URL of this action
    
    unless ($verified_url) {
        return $self->render_not_found;
    }

    $self->render(text => "$verified_url has been verified");

=head1 DESCRIPTION

L<MojoX::URL::Sign::Plugin> is a simple L<Mojolicious> plugin to expose L<MojoX::URL::Sign> C<sign_url>
and C<verify_url> methods as helpers.

The name of the helpers have the same name as the methods which they point to.

See L<MojoX::URL::Sign> for detailed information.

=head1 HELPER METHODS

=head2 sign_url

    my $signed_url = $self->sign_url($url_to_sign); # Sign a specifiec URL
    my $signed_url = $self->sign_url;               # Sign the URL of the current controller/action

=head2 verify_url

    my $verified_url = $self->verify_url;

If URL verified OK, then C<$verified_url> is the original URL without the signature.
Otherwise it will be C<undef>

=head1 CAVEATS

=over 4

=item * URL must be absolute, and with scheme and host

If using L<Mojolicious::Controller/url_for>, ensure that you use L<-E<gt>to_abs|Mojo::URL/to_abs>

=back

=head1 AUTHOR

Ben Vinnerd, C<ben@vinnerd.com>

=cut
