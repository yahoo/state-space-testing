# -*- sh -*- expects to be sourced, not exec'ed

#
# usage
#    source ${0%/*}/rigging.sh
#    (
#      $exe --debug --verbose ...other...arguments...
#    ) >& $output &&
#    diff $golden $output &&
#    successful
#

f=${0##*/}
b=${f%.test}
name=$b

# NOT exe=${PWD##*/}
# PWD is either  .../statespace-tooling
#     or else   .../statespace-tooling/tests/pcd
exe=full-of-gravel

# we want a full path here so that testers can chdir and still get the same executable
topdir=$(dirname $(dirname $(cd ${0%/*}; pwd)))

bindir=$topdir/bin
libdir=$topdir/lib
libexecdir=$topdir/libexec
pkglibexecdir=$topdir/libexec/iab/privacychain

export PATH="${bindir}:${libexecdir}:${pkglibexecdir}:$PATH"

# output & golden for the test
# WATCHOUT for the ./ as command line vs Makefile.am invocations differ!
dedot0=${0#./}
output=${dedot0%.test}.out
golden=${dedot0%.test}.gold

# expects incendiary-sophist >= 0.3.0 with the packaged sysexits.sh and compare_output.sh
# which supply (shell) function difference() {...} and function successful() {...}
source ${libdir?}/tests/config.sh && 
source ${incendiary_sophist_riggingdir}/sysexits.sh &&
source ${incendiary_sophist_riggingdir}/compare_output.sh ||
exit 70

function canonicalize_output_file() {
    local input=$1; shift
    local output=$1; shift
    perl -n -e '
# get rid of the actual version number in output and golden files
s/version v\d+\.\d+\.\d+/version vMAJOR.MINOR.PATCH/g;
# remove the timestamps
s/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]/YYYY-MM-DD HH:MM:SS/;
#
# get rid of the pesky lt- prefix that libtool puts into arv0
# Quit once we have identified that this is the pct usage message
s/lt-//g;
if (/^[Uu]sage: .*/) { exit 0; }
' "$input" > "$output" || return ${EX_NOINPUT:-66}
}

trap cleanup EXIT
trap failing ERR
# ... the caller must test something & call 'successful' to end
