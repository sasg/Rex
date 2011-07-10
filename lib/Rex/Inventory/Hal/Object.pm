#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package Rex::Inventory::Hal::Object;

use strict;
use warnings;

sub new {
   my $that = shift;
   my $proto = ref($that) || $that;
   my $self = { @_ };

   bless($self, $proto);

   return $self;
}

sub has {

   my ($class, $keys) = @_;
   for my $k (@{$keys}) {
      my $key      = $k->{"key"};
      my $accessor = $k->{"accessor"};

      no strict 'refs';
      *{"${class}::get_$accessor"} = sub {
         my ($self) = @_;
         if($k->{"parent"}) {
            return $self->parent()->get($key);
         }
         else {
            return $self->get($key);
         }
      };

      push(@{"${class}::items"}, $k);
      use strict;
   }

}


# returns the parent of the current object
sub parent {

   my ($self) = @_;
   return $self->{"hal"}->get_object_by_udi($self->{'info.parent'});

}

sub get {

   my ($self, $key) = @_;

   if(ref($self->{$key}) eq "ARRAY") {
      return @{$self->{$key}};
   }

   return exists $self->{$key} ?
               $self->{$key} :
               "";

}

sub get_all {

   my ($self) = @_;

   my $r = ref($self);

   no strict 'refs';
   my @items = @{"${r}::items"};
   use strict;

   my $ret;
   for my $itm (@items) {
      my $f = "get_" . $itm->{"accessor"};
      $ret->{$itm->{"accessor"}} = $self->$f();
   }

   return $ret;
}

1;