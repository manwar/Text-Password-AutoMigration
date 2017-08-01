package Text::Password::MD5;
our $VERSION = "0.01";

use 5.008001;
use Moose;
extends 'Text::Password::CoreCrypt';

use Carp;
use Crypt::PasswdMD5;

=encoding utf-8

=head1 NAME

Text::Password::MD5 - generate and verify Password with unix_md5_crypt()

=head1 SYNOPSIS

 my $pwd = Text::Password::MD5->new();
 my( $raw, $hash ) = $pwd->genarate();          # list context is required
 my $input = $req->body_parameters->{passwd};
 my $data = $pwd->encrypt($input);              # salt is made automatically
 my $flag = $pwd->verify( $input, $data );

=head1 DESCRIPTION

Text::Password::MD5 is the part of Text::Password::AutoMigration.

B<DON'T USE> directly.

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
    return super() if $data =~ /^[!-~]{13}$/; # with crypt in Perl

     die __PACKAGE__. " doesn't allow any Wide Characters or white spaces\n"
    if $input !~ /[!-~]/ or $input =~ /\s/;
     croak "Crypt::PasswdMD5 makes 34bytes hash strings. Your data must be wrong."
    if $data !~ /^\$1\$[!-~]{1,8}\$[!-~]{22}$/;

    return $data eq unix_md5_crypt( $input, $data );
};

=item nonce($length)

generate the strings with enough strength

default length is 8

=item encrypt($raw)

returns hash with CORE::crypt

salt will be made automatically

=cut

override 'encrypt' => sub {
    my $self = shift;
    my $input = shift;
    my $min = $self->minimum();
    croak __PACKAGE__ ." requires at least $min length" if length $input < $min;
     die __PACKAGE__. " doesn't allow any Wide Characters or white spaces\n"
    if $input !~ /[!-~]/ or $input =~ /\s/;

    my $salt = shift || $self->nonce();
    carp "warning: short lengths salt is set. you don't have to." if length($salt) < 8;
    carp "warning: too many string lengths for salt. unix_md5_crypt() ignores more than 8." if $salt and length($salt) > 8;

    return unix_md5_crypt( $input, $salt );
};

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
