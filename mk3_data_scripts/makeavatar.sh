#!/bin/sh
APREF=lighthouse-costest-av


#TODO: Separate out the lighthouse data by droptol so each one gets its own tree.
# Override data inspector and make the sigmas continuous and not discrete
# Postprocessin tool: Ex post facto tree manipulation to condense parent/child nodes with the same cut object into a single node with range children

if [ 1 -eq 0 ]; then
cat lighthouse-costest.data  | sed 's/%/#labels /' > $APREF.data

./data_inspector --write-names-file --file-stem $APREF

./avatardt --train -o avatar --seed=24601 -f $APREF

./tree2dot $APREF.trees
fi

./replace-indices-in-dot-file-with-labels.py $APREF.trees-1.dot  $APREF.names > $APREF.final.dot

dot -Tpng $APREF.final.dot -o $APREF-1.png 



if [ 1 -eq 0 ]; then


# Testing data
echo "generate_testing_mesh; quit" | matlab -nodesktop -nosplash

NUMALGS=8

I=1
while [ $I -lt `expr $NUMALGS + 1` ]; do
    cp testmesh_$I.data $APREF.test
    ./avatardt --test -o avatar --output-predictions --output-probabilities -f $APREF
    cat $APREF.pred | sed 's/^#/%/' > testmesh_$I.pred
    I=`expr $I + 1`
done

fi