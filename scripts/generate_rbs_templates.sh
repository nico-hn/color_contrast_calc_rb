#!/bin/sh

for RB_FILE in `find lib -type f -name "*.rb"`
do
    SIG_FILE=`echo $RB_FILE | sed -e 's/^lib/sig_gen/' -e 's/\.rb$/.gen.rbs/'`
    typeprof $RB_FILE > $SIG_FILE
done
