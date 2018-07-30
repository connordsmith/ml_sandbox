#!/bin/sh
OLD_DATA=muelu_sampling.dat
CLEAN_FEATURE=feature.txt
CWD=`pwd`
AWKFILE=replace_features.awk 

for I in problem_*; do
    echo "*** $I ***"
    cd $I

    mv $OLD_DATA ${OLD_DATA}-bak
    awk -f $CWD/$AWKFILE $CLEAN_FEATURE $OLD_DATA-bak > $OLD_DATA
    cd $CWD
done
