#!/bin/sh
XML_TEMPLATE=tc-problem-and-solver.xml-template
XML_FEATURE=feature.xml
VERBOSE_FEATURE=verbose_feature.txt
CLEAN_FEATURE=feature.txt
CWD=`pwd`

# This script recalculates the problem features (e.g. if new features are desired)
# It dumps the output in $CLEAN_FEATURE

for I in problem_*; do
    echo "*** $I ***"
    cd $I
    aprepro $XML_TEMPLATE | tail -n+2 >  $XML_FEATURE
    ./TrilinosCouplings_IntrepidPoisson_Pamgen_Tpetra.exe --exitAfterAssembly --verbose --inputParams=$XML_FEATURE | sed -n '/Problem Statistics/,/TimeMonitor/p' | head -n -4 | tail -n +2 > $VERBOSE_FEATURE
    cat $VERBOSE_FEATURE | cut -f2 -d= | cut -f1 -d'[' > $CLEAN_FEATURE
    cd $CWD
done