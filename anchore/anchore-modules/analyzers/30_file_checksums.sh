#!/bin/bash

ANALYZERNAME="file_checksums"

# source anchore utility shell functions
. `dirname $0`/../shell-utils/anchore_module_utils.sh

# parse the CMDLINE, perform checks and set up useful variables
init_analyzer_cmdline $ANALYZERNAME $@
if [ "$?" != "0" ]; then
    # input didn't parse correctly
    exit 1
fi

if [ ! -d "$OUTPUTDIR" ]; then
    mkdir -p $OUTPUTDIR
fi

if [ ! -d "$UNPACKDIR/rootfs/" ]; then
    echo "ERROR:${0}_MSG:Cannot find saved filesystem, skipping analysis"
    exit 1
fi

if [ -f "$OUTPUTDIR/files.md5sums" ]; then
    echo "WARN:${0}_MSG:all output files already exist, skipping"
    exit 0
fi

if [ -f "${UNPACKDIR}/squashed.tar" ]; then
    tar tf $UNPACKDIR/squashed.tar | sort | uniq > $UNPACKDIR/files.all
fi

for f in `cat $UNPACKDIR/files.all`
do
    if [ -f "$UNPACKDIR/rootfs/$f" -a ! -h "$UNPACKDIR/rootfs/$f" ]; then
	MD5=`md5sum $UNPACKDIR/rootfs/$f | awk '{print $1}'`
    else
	MD5="DIRECTORY_OR_OTHER"
    fi
    echo "$f $MD5" >> $UNPACKDIR/md5s
done

if [ -f "$UNPACKDIR/md5s" ]; then
    cat $UNPACKDIR/md5s | sort -k 1 > $OUTPUTDIR/files.md5sums
fi



