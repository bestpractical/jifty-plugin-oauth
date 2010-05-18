use strict;
use warnings;

package Jifty::Plugin::OAuth::Command::AddConsumer;

package Jifty::Script::Addconsumer;

use base qw/Jifty::Script/;

=head1 NAME

Jifty::Script::AddConsumer - Add OAuth consumers to your database

=head1 SYNOPSIS

    $ jifty addconsumer --name='Twitter' --url='http://twitter.com'
    Created consumer
        id:            6
        name:          Twitter
        url:           http://twitter.com
        consumer key:  642859228261845
        shared secret: 779182665606157

=head1 DESCRIPTION

=head2 options

=over 4

=item name

The name of the service (e.g. Twitter)

=item url

The service's website (optional)

=item key

The unique identifier for the service; if left unspecified, a random one will
be generated. You probably don't want to specify the key.

This must be communicated back to the consumer.

=item secret

The shared secret for the service; if left unspecified, a random one will
be generated. You probably don't want to specify the secret.

This must be communicated back to the consumer.

=back

=cut

sub options {
    my $self = shift;
    return (
        $self->SUPER::options,
        "name=s"   => "name",
        "url=s"    => "url",
        "key=s"    => "key",
        "secret=s" => "secret",
    );
}

=head2 run

Creates a new L<Jifty::Plugin::OAuth::Model::Consumer> record.

=cut

sub run {
    my $self = shift;
    Jifty->new;

    ($self->{name}||'') =~ /\S/ or die "name is required";

    # generate a random key
    $self->{key} ||= do {
        my $r = rand;
        $r =~ s/0\.//;
        $r
    };

    # and a random secret
    $self->{secret} ||= do {
        my $r = rand;
        $r =~ s/0\.//;
        $r
    };

    my $consumer = Jifty::Plugin::OAuth::Model::Consumer->new(current_user => Jifty::CurrentUser->superuser);
    my ($ok, $msg) = $consumer->create(
        name => $self->{name},
        ($self->{url} =~ /\S/ ? (url  => $self->{url}) : ()),

        consumer_key => $self->{key},
        secret => $self->{secret},
    );

    if ($ok) {
        print << "RESULTS";
Created consumer
    id:            @{[ $consumer->id ]}
    name:          $self->{name}
    url:           @{[ $self->{url} || '(none)' ]}
    consumer key:  $self->{key}
    shared secret: $self->{secret}
RESULTS
    }
    else {
        die "Unable to create consumer: $msg\n";
    }
}

=head2 filename

This is used as a hack to get L<App::CLI> to retrieve our POD correctly.

Inner packages are not given in C<%INC>. If anyone finds a way around this,
please let us know.

=cut

sub filename { __FILE__ }

=head1 SEE ALSO

L<Jifty::Plugin::OAuth>

=head1 COPYRIGHT AND LICENSE

Copyright 2010 Best Practical Solutions

This is free software and may be modified and distributed under the same terms as Perl itself.

=cut

1;

