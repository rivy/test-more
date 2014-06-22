package Test::Builder::Stream::Tester;
use strict;
use warnings;

use Test::Builder::Stream;

use Scalar::Util qw/blessed/;

use Test::Builder::Provider;
provides qw/intercept/;

sub intercept(&) {
    my ($code) = @_;

    my @results;

    local $@;
    my $ok = eval {
        Test::Builder::Stream->intercept(sub {
            my $stream = shift;
            $stream->exception_followup;

            $stream->listen(INTERCEPTOR => sub {
                my ($item) = @_;
                push @results => $item;
            });
            $code->();
        });
        1;
    };
    my $error = $@;

    die $error unless $ok || (blessed($error) && $error->isa('Test::Builder::Result'));

    return \@results;
}

1;
