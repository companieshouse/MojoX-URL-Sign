package MojoX::URL::Sign;

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

    my $signature = $self->_sign($url, $salt);

    $url->query([signature => $signature]);

    return $url->to_string;
}

# ------------------------------------------------------------------------------

sub verify_url {
    my ($self, $url, $salt) = @_;

    $url = new Mojo::URL($url) unless (ref($url) eq 'Mojo::URL');

    my $url_cloned = $url->clone; # URL object needs to be modified, clone so we don't modify the original if passed in by ref
    my $signature = $url_cloned->query->param('signature');

    $url_cloned->query([signature => undef]); # Drop the signature (Mojo::URL merge param syntax)
    print($url_cloned->to_string . "\n");

    return $self->_sign($url_cloned, $salt) eq $signature ? 1 : 0;
}

# ------------------------------------------------------------------------------

sub _sign {
    my ($self, $mojo_url, $salt) = @_;

    return encode_base64url(sha256(join('.', $mojo_url->to_string, $salt)));
}

# ------------------------------------------------------------------------------

1;