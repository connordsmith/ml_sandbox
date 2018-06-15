import csv
import random

# TODO divide data into training/testing data
# TODO divide data into categories by drop_tol

r = csv.reader(open('viz-costest.data'))
lines = list(r)

i = -1

for line in lines:
    i += 1
    if (i > 0):
    	if (float(line[15]) > .8):
    	    line[15] = 1
	elif (float(line[15]) > 0):
	    line[15] = 0
	else:
	    line[15] = -1

train_count = float(len(lines)) * .8

train_writer = csv.writer(open('three_classes_train.data','w'))
test_writer = csv.writer(open('three_classes_test.data','w'))

i = -1

for line in lines:
    i += 1
    if (i == 0):
	train_writer.writerow(line)
      	test_writer.writerow(line)
    elif (i < train_count):
	train_writer.writerow(line)
    else:
	test_writer.writerow(line)


#writer = csv.writer(open('three-classes.data','w'))
#writer.writerows(lines)
