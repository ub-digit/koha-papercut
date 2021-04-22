#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"
source "$script_dir/config"

DIR="/opt/koha-papercut"
EOP_FILE="eop_users.txt"
PC_FILE="pc_users.txt"

cd "$DIR"
rm -f "$EOP_FILE"
rm -f "$PC_FILE"

/usr/sbin/koha-shell $KOHA_INSTANCE -c "perl updated_borrowers.pl"

if test -f "$EOP_FILE"
then
    scp "$EOP_FILE" root@intra.ub.gu.se:/opt/eop_update/data/last_updated_eop.tab
    ssh root@intra.ub.gu.se "/opt/eop_update/run_update_users_email.sh"
fi

if test -f "$PC_FILE"
then
    scp "$PC_FILE" root@intra.ub.gu.se:/opt/load_pc_user/data/new_users
    ssh root@intra.ub.gu.se "/opt/load_pc_user/run_load_new_users.sh"
fi
