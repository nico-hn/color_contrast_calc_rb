for RB_FILE in `cat sig_gen/lib_files_without_rbs.txt`
do
    TMP_RBS=sig_gen/rgb.tmp
    SIG_FILE=`echo $RB_FILE | sed -e 's/^lib/sig_gen/' -e 's/\.rb$/.gen.rbs/'`
    echo ==== $RB_FILE ====
    typeprof $RB_FILE `find sig -type f -name '*.rbs'` `find sig_gen -type f -name '*.gen.rbs'` > $TMP_RBS
    mv $TMP_RBS $SIG_FILE
done
