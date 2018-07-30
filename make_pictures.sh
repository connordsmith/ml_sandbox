


for i in 0.001 0.005 0.01 0.025 0.05 0.075 0.0 0.1
do
dot -Tpng $i.trees-1.dot > $i-tree.png
done
