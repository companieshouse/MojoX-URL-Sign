package MojoX::URL::Sign::Plugin;

use Mojo::Base 'Mojolicious::Plugin';

use MojoX::URL::Sign;

sub register {
    my $self = shift;
    my $app  = shift;
    my $arg  = ref($_[0]) eq 'HASH' ? shift : {@_};

    die('No salt supplied') unless (defined($arg->{salt}));

    $app->helper(sign_url   => sub { return MojoX::URL::Sign->sign_url(shift, $arg->{salt}); });
    $app->helper(verify_url => sub { return MojoX::URL::Sign->verify_url(shift, $arg->{salt}); });

    return;
}

1;
