# NAME

MojoX::URL::Sign - Sign and verify URLs to prevent tampering

# SYNOPSIS

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

# DESCRIPTION

A [Mojo::URL](https://metacpan.org/pod/Mojo::URL) based URL signer and verifier, to ensure that URLs you give out have not been
tampered with.

The signed URL is just the original supplied URL with a `signature=xxx` appended onto the query
params. This value is stripped later on in the ["verify\_url"](#verify_url) method (see below).

# METHODS

## sign\_url

Signs a URL, appends a `signature=xxx` param onto the querystring. Will fail if `signature`
is already present.

    my $signed_url = MojoX::URL::Sign->sign_url('http://example.com/page', 'secret-salt');

## verify\_url

Verifies that the signature of a previously signed URL is correct and hasn't been tampered with.

    my $verified_url = MojoX::URL::Sign->verify_url(
        'http://example.com/page?foo=bar&signature=I9IBKxd8la7itJnCA1rGSFccJ_r8PiRd7c8ywkozHUU',
        'secret-salt',
    );

`$verified_url` will be the original URL (i.e. without `signature=xxx`) if it verifies OK.
Otherwise, it will be `undef`.

# PRIVATE METHODS

## \_sign

Generates the signature.

# CAVEATS

- URL to sign cannot contain `signature`

    The URL to sign cannot contain a query parameter named `signature`, because it uses that to
    hold the signature! If your URL does contain it, then [MojoX::URL::Sign](https://metacpan.org/pod/MojoX::URL::Sign) will `die()`

# AUTHOR

Ben Vinnerd, `ben@vinnerd.com`
