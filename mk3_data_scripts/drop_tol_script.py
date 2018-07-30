import csv

r = csv.reader(open('three_classes.data'))
lines = list(r)

i = -1    

drop_tol_list = list()

for line in lines:
    i += 1
    if (i > 0):
	this_drop_tol = float(line[10])
	if not (this_drop_tol in drop_tol_list):
	    drop_tol_list.append(this_drop_tol)


for c in range(0,len(drop_tol_list)):
    writer = csv.writer(open('./droptols/drop_tol_'+str(drop_tol_list[c])+'.data','w'))
    i = -1
    for line in lines:
        i += 1
        if (i == 0):
	    writer.writerow(line)
        elif (i > 0 and float(line[10]) == drop_tol_list[c]):
	    writer.writerow(line)
	

