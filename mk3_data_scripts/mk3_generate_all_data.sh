#!/bin/sh

ALGORITHM="-a 2"
PROBLEM="-p 3,4,5,6,7,8,9"

SOLVETIME="-r 13"
COSTEST="-r 14"

LHT_GOOD="-g 0.9"
VIZ_ALG="-a 2,10,11,12,13"

PYSCRIPT=./mk3-gather-raw-data.py

##############################


$PYSCRIPT -m lighthouse $LHT_GOOD $ALGORITHM $PROBLEM $SOLVETIME > lighthouse-solvetime.data
$PYSCRIPT -m lighthouse $LHT_GOOD $ALGORITHM $PROBLEM $COSTEST > lighthouse-costest.data


$PYSCRIPT -m showbest  $ALGORITHM $PROBLEM $SOLVETIME  > showbest-solvetime.data
mv stretch-showbest-algenum.txt stretch-showbest-algenum-solvetime.txt
$PYSCRIPT -m showbest $ALGORITHM $PROBLEM $COSTEST > showbest-costest.data
mv stretch-showbest-algenum.txt stretch-showbest-algenum-costest.txt

$PYSCRIPT -m viz $VIZ_ALG $PROBLEM $SOLVETIME > viz-solvetime.data
-

$PYSCRIPT -m viz $VIZ_ALG $PROBLEM $COSTEST > viz-costest.data
