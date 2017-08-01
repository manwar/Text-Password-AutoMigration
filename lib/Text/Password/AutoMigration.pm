package Text::Password::AutoMigration;
our $VERSION = "0.01";

use 5.008001;
use Moose;
extends 'Text::Password::SHA';

sub BUILD {
    my $self = shift;
    return Text::Password::SHA->new(@_);
}

=encoding utf-8

=head1 NAME

Text::Password::SHA - generate and verify Password with SHA

=head1 SYNOPSIS

 my $pwd = Text::Password::SHA->new();
 my( $raw, $hash ) = $pwd->genarate();          # list context is required
 my $input = $req->body_parameters->{passwd};
 my $data = $pwd->encrypt($input);              # salt is made automatically
 my $flag = $pwd->verify( $input, $data );

=head1 DESCRIPTION

Text::Password::SHA is the part of Text::Password::AutoMigration.

=head2 Constructor and initialization

=head3 new()

no arguments are required

=head2 Methods and Subroutines

=over

=item verify( $raw, $hash )

returns true if the verify is success

=cut

override 'verify' => sub {
    my $self = shift;
    my ( $input, $data ) = @_;
    die __PACKAGE__. " doesn't allow any Wide Characters or white spaces\n"
    if $input !~ /[!-~]/ or $input =~ /\s/;

     return super() if $data =~ /^\$[56]\$([!-~]{1,8})\$[!-~]{43,86}$/
    or $data =~ /^[0-9a-f]{40}$/i;
    return $self->Text::Password::MD5::verify(@_);
};

=item nonce($length)

generate the strings with enough strength

default length is 8

=item encrypt($raw)

returns hash with CORE::crypt
 
salt will be made automatically

=item generate($length)

genarates pair of new password and it's hash

not much readable characters(0Oo1Il|!2Zz5sS\$6b9qCcKkUuVvWwXx.,:;~\-^'"`) are fallen

default lebgth is 8

=back

=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 LICENSE

Copyright (C) Yuki Yoshida(worthmine).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Yuki Yoshida(worthmine) E<lt>worthmine@gmail.comE<gt>
