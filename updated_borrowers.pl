BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use Koha::Patron;
use Koha::Patrons;
use Koha::DateUtils qw(dt_from_string);

my $dir = "/opt/koha-papercut";

my $dtf = Koha::Database->new->schema->storage->datetime_parser;
my $date = dt_from_string();
$date->subtract(hours => 1);

# EOP: borrowernumber cardnumber email categorycode (REQ: email)
# PC: borrowernumber cardnumber pnr email categorycode

my $patrons = Koha::Patrons->search({
    updated_on => {'>', $dtf->format_datetime($date) },
    categorycode => {-in => ["EX", "UX", "FR", "SR", "FX"]}
});

use Data::Dumper;

open(EOP_USERS, ">$dir/eop_users.txt");
open(PC_USERS, ">/$dir/pc_users.txt");

foreach my $patron (@{$patrons->unblessed}) {
    print_eop(EOP_USERS, $patron);
    print_pc(PC_USERS, $patron);
}

close(PC_USERS);
close(EOP_USERS);

sub print_eop {
    my ($fp, $patron) = @_;

    return if(!$patron->{email} || $patron->{email} =~ /^\s*$/);

    my @row = ($patron->{borrowernumber},
        $patron->{cardnumber},
        $patron->{email},
        $patron->{categorycode});
    print $fp join("\t", @row)."\n";
}

sub print_pc {
    my ($fp, $patron) = @_;

    my $patronobj = Koha::Patrons->search({borrowernumber => $patron->{borrowernumber}})->next;
    my $pnrobj = $patronobj->get_extended_attribute("PNR");
    my $pnr = "";
    if ($pnrobj) {
        $pnr = $pnrobj->attribute;
    }

    my @row = ($patron->{borrowernumber},
        $patron->{cardnumber},
        $pnr,
        $patron->{email},
        $patron->{categorycode});
    print $fp join("\t", @row)."\n";
}

