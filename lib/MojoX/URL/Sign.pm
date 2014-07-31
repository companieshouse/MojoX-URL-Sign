package MojoX::URL::Sign;
# ABSTRACT: Sign and verify URLs to prevent tampering

our $VERSION = '0.30';

use Mojo::Base -base;

use Mojo::URL;
use Digest::SHA qw/sha256/;
use MIME::Base64 qw/encode_base64url/;

# ------------------------------------------------------------------------------

sub sign_url {
    my ($self, $url, $salt) = @_;

    die('No salt supplied') unless (defined($salt));
    $url = new Mojo::URL($url) unless (ref($url) eq 'Mojo::URL');

    if (defined($url->query->param('signature'))) {
        die('URL already contains a signature');
    }

    $url->query([signature => $self->_sign($url, $salt)]);

    return $url;
}

# ------------------------------------------------------------------------------

sub verify_url {
    my ($self, $url, $salt) = @_;

    die('No salt supplied') unless (defined($salt));
    $url = new Mojo::URL($url) unless (ref($url) eq 'Mojo::URL');

    my $url_cloned = $url->clone; # URL object needs to be modified, clone so we don't modify the original if passed in by ref
    my $signature = $url_cloned->query->param('signature');

    $url_cloned->query([signature => undef]); # Drop the signature (Mojo::URL merge param syntax)

    return $self->_sign($url_cloned, $salt) eq $signature ? $url_cloned : undef;
}

# ------------------------------------------------------------------------------

sub _sign {
    my ($self, $mojo_url, $salt) = @_;

    return encode_base64url(sha256(join('.', $mojo_url->to_string, $salt)));
}

# ------------------------------------------------------------------------------

1;

=encoding utf8

=head1 NAME

MojoX::URL::Sign - Sign and verify URLs to prevent tampering

=head1 SYNOPSIS

    use MojoX::URL::Sign;
    use Mojo::URL;
    use v5.10;

    my $signer     = new MojoX::URL::Sign;
    my $salt       = 'secret-salt';
    my $url        = new Mojo::URL('http://example.com/page')->query(foo => 'bar');
    my $signed_url = $signer->sign_url($url, $salt);
    say("Signed URL: $signed_url");

    my $verified_url = $signer->verify_url($signed_url, $salt);

    if ($verified_url) {
        say("Verified URL: $verified_url");
    }
    else {
        die("URL was not verified, invalid signature");
    }

    # You can also just use the methods as class methods, e.g.
    my $signed_url   = MojoX::URL::Sign->sign_url('http://example.com/page?foo=bar', $salt);
    my $verified_url = MojoX::URL::Sign->verify_url($signed_url, $salt);

=head1 DESCRIPTION

A L<Mojo::URL> based URL signer and verifier, to ensure that URLs you give out have not been
tampered with.

The signed URL is just the original supplied URL with a C<signature=xxx> appended onto the query
params. This value is stripped later on in the L</verify_url> method (see below).

=head1 METHODS

=head2 sign_url

Signs a URL, appends a C<signature=xxx> param onto the querystring. Will fail if C<signature>
is already present.

    my $signed_url = MojoX::URL::Sign->sign_url('http://example.com/page', 'secret-salt');

=head2 verify_url

Verifies that the signature of a previously signed URL is correct and hasn't been tampered with.

    my $verified_url = MojoX::URL::Sign->verify_url(
        'http://example.com/page?foo=bar&signature=I9IBKxd8la7itJnCA1rGSFccJ_r8PiRd7c8ywkozHUU',
        'secret-salt',
    );

C<$verified_url> will be the original URL (i.e. without C<signature=xxx>) if it verifies OK.
Otherwise, it will be C<undef>.

=head1 PRIVATE METHODS

=head2 _sign

Generates the signature.

=head1 CAVEATS

=over 4

=item * URL to sign cannot contain C<signature>

The URL to sign cannot contain a query parameter named C<signature>, because it uses that to
hold the signature! If your URL does contain it, then L<MojoX::URL::Sign> will C<die()>

=back

=head1 AUTHOR

Ben Vinnerd, C<ben@vinnerd.com>

=cut
