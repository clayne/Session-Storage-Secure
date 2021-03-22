use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::Fatal;

use Session::Storage::Secure;

my $data = {
    foo => 'bar',
    baz => 'bam',
};

my $secret = "serenade viscount secretary frail";

sub _gen_store {
    my ($config) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $store = Session::Storage::Secure->new(
        secret_key => $secret,
        %{ $config || {} },
    );
    ok( $store, "created a storage object" );
    return $store;
}

sub _replace {
    my ( $string, $index, $value ) = @_;
    my @parts = split qr/~/, $string;
    $parts[$index] = $value;
    return join "~", @parts;
}

subtest "bad data" => sub {
    my $store = _gen_store;
    like(
        exception { $store->encode( { foo => bless {} } ) },
        qr/Encoding error/,
        "Invalid data throws encoding error",
    );
};

subtest "bad protocol version" => sub {
    for my $pv ( -1, 0, 3 ) {
        like(
            exception {
                Session::Storage::Secure->new(
                    secret_key       => $secret,
                    protocol_version => $pv,
                )
            },
            qr/Invalid protocol version for encoding/,
            "Invalid protocol_version $pv throws error",
        );
    }
};

done_testing;
# COPYRIGHT
