#!/bin/bash
# Note: This list is logarithmically spaced
STRETCHES=(1.00     1.17     1.37     1.61     1.89     2.21     2.59     3.04     3.56     4.18     4.89     5.74     6.72     7.88     9.24    10.83    12.69    14.87    17.43    20.43    23.95    28.07    32.90    38.57    45.20    52.98    62.10    72.79    85.32   100.00)
SIGMAS=(1e-6 1e-4 1e-2 1e0 1e2 1e4 1e6)

#STRETCHES=(1.00 5.00)
#SIGMAS=(1e0 1e4)
LINK_FILES="TrilinosCouplings_IntrepidPoisson_Pamgen_Tpetra.exe dakota_lhs.in"
SED_IN_FILE="tc-problem-and-solver.xml-template"
SED_OUT_FILE="tc-problem-and-solver.xml-template"
COPY_IN_FILE="run_muelu_mk3.sh-template"
COPY_OUT_FILE="run_muelu.sh"
RUN_LINE="dakota -i dakota_lhs.in"

########################################
CWD=`pwd`

echo "*** Setup Phase ***"
for (( I=0; I<${#STRETCHES[@]}; I++ )); do
    SI=${STRETCHES[$I]}
    for (( J=$I; J<${#STRETCHES[@]}; J++ )); do	
	SJ=${STRETCHES[$J]}
        for (( K=0; K<${#SIGMAS[@]}; K++ )); do	
  	  SK=${SIGMAS[$K]}

  	  DIR=problem_${SI}_${SJ}_${SK}
	  if [ -d $DIR ]; then :
	  else mkdir $DIR; fi
	  
	  cd $DIR
	  for LL in $LINK_FILES; do
	      ln -s $CWD/$LL .
	  done

	  cp $CWD/$COPY_IN_FILE $COPY_OUT_FILE
	  
	  cat $CWD/$SED_IN_FILE | sed "s/_MXS_/$SI/g" | sed "s/_MYS_/$SJ/g"  | sed "s/_MAXSIGMA_/$SK/g" > $SED_OUT_FILE
	  chmod +x $SED_OUT_FILE
	  cd $CWD
	done
    done       
done

echo "*** Run Phase ***"
for (( I=0; I<${#STRETCHES[@]}; I++ )); do
    SI=${STRETCHES[$I]}
    for (( J=$I; J<${#STRETCHES[@]}; J++ )); do	
	SJ=${STRETCHES[$J]}
	for (( K=0; K<${#SIGMAS[@]}; K++ )); do	
  	    SK=${SIGMAS[$K]}
    	    DIR=problem_${SI}_${SJ}_${SK}

	    cd $DIR
	    echo " Running $DIR"
	    $RUN_LINE
	    
            # Comment out if you want the post-mortem
	    rm -rf workdir*
	    cd $CWD
	done
    done
done