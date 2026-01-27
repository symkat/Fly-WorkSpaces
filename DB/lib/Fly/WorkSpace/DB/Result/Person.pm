use utf8;
package Fly::WorkSpace::DB::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Fly::WorkSpace::DB::Result::Person

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Serializer");

=head1 TABLE: C<person>

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: gen_random_uuid()
  is_nullable: 0
  retrieve_on_insert: 1
  size: 16

=head2 name

  data_type: 'citext'
  is_nullable: 0

=head2 email

  data_type: 'citext'
  is_nullable: 0

=head2 is_enabled

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 is_admin

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "uuid",
    default_value => \"gen_random_uuid()",
    is_nullable => 0,
    retrieve_on_insert => 1,
    size => 16,
  },
  "name",
  { data_type => "citext", is_nullable => 0 },
  "email",
  { data_type => "citext", is_nullable => 0 },
  "is_enabled",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "is_admin",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<person_email_key>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("person_email_key", ["email"]);

=head2 C<person_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("person_name_key", ["name"]);

=head1 RELATIONS

=head2 auth_password

Type: might_have

Related object: L<Fly::WorkSpace::DB::Result::AuthPassword>

=cut

__PACKAGE__->might_have(
  "auth_password",
  "Fly::WorkSpace::DB::Result::AuthPassword",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sprites

Type: has_many

Related object: L<Fly::WorkSpace::DB::Result::Sprite>

=cut

__PACKAGE__->has_many(
  "sprites",
  "Fly::WorkSpace::DB::Result::Sprite",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07052 @ 2026-01-14 04:53:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:r3CsB4ia2CF7xpb50ghHhA


sub get_sprites {
    my ( $self ) = @_;

    my @results = $self->search_related('sprites', {}, { order_by => { -desc => [  qw/created_at/ ] } } )->all;
    
    return [ map { $_->as_hash } @results ];

}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
