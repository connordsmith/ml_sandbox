#!/bin/bash
# Note: This list is logarithmically spaced
#STRETCHES=(0.50  0.97  1.89  3.69  7.17  13.95  27.14  52.82  102.78 200.00)
STRETCHES=(0.5000    0.6854    0.9394    1.2877    1.7651    2.4195    3.3164    4.5459    6.2312    8.5413   11.7078   16.0482   21.9977   30.1527   41.3311   56.6536   77.6566  106.4459  145.9081  200.0000)
SIGMAS=(1.0)

#STRETCHES=(1.00 5.00)
#SIGMAS=(1e0)
LINK_FILES="TrilinosCouplings_IntrepidPoisson_Pamgen_Tpetra.exe avatar.names avatar.trees solver-live.xml-template"
SED_IN_FILE="mesh.xml-template"
SED_OUT_FILE="mesh.xml-template"
APR_OUT_FILE="mesh.xml"

FINAL_FILE="tc-live.xml"
COPY_IN_FILE="run_muelu_live.sh-template"
COPY_OUT_FILE="run_muelu_live.sh"
RUN_LINE="./run_muelu_live.sh"

########################################
CWD=`pwd`
if [ $# -ne 1 ]; then 
    echo "syntax: $0 [b|r|a|c]"
    exit 1
fi


###########################
if [ "$1" == "b" ]; then
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
          aprepro $SED_OUT_FILE $APR_OUT_FILE

          echo "<ParameterList> " > $FINAL_FILE
          cat $APR_OUT_FILE >> $FINAL_FILE
          cat solver-live.xml-template >> $FINAL_FILE
          echo "</ParameterList> " >> $FINAL_FILE
	  chmod +x $FINAL_FILE

	  cd $CWD
	done
    done       
done
###########################
elif [ "$1" == "r" ]; then
echo "*** Run Phase ***"
for (( I=0; I<${#STRETCHES[@]}; I++ )); do
    SI=${STRETCHES[$I]}

    WAIT=""
    for (( J=$I; J<${#STRETCHES[@]}; J++ )); do	
	SJ=${STRETCHES[$J]}
	for (( K=0; K<${#SIGMAS[@]}; K++ )); do	
  	    SK=${SIGMAS[$K]}
    	    DIR=problem_${SI}_${SJ}_${SK}

	    cd $DIR
	    echo " Running $DIR"
	    $RUN_LINE &
            PID=$!
            WAIT="$WAIT $PID"	    
	    cd $CWD
	done
    done
    wait $WAIT
done
###########################
elif [ "$1" == "a" ]; then
echo "*** Analysis Phase ***"
for (( I=0; I<${#STRETCHES[@]}; I++ )); do
    SI=${STRETCHES[$I]}
    for (( J=$I; J<${#STRETCHES[@]}; J++ )); do	
	SJ=${STRETCHES[$J]}
	for (( K=0; K<${#SIGMAS[@]}; K++ )); do	
  	    SK=${SIGMAS[$K]}
    	    DIR=problem_${SI}_${SJ}_${SK}

	    STR=`cat $DIR/results.out`
            DT=`echo $STR | cut -f1 -d,`
            IT=`echo $STR | cut -f2 -d,`
            echo "$SI $SJ   $DT $IT"
	    
	done
    done
done
###########################
elif [ "$1" == "c" ]; then
    rm -rf problem_*;

###########################
else
    echo "syntax: $0 [b|r|a|c]"
fi
