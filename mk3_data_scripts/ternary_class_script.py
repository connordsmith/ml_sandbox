import csv

#After creating the 'viz-costest.data' file with the gather-raw-data script, 
#run this program to create a .data file with three-class classifications
#for costEst

r = csv.reader(open('viz-costest.data'))
lines = list(r)

i = -1

goodness_threshold = .8

for line in lines:
    i += 1
    if (i > 0):
	#If this sample has negative iterations, this sample is 
	#classified as CRASH (-1)
	if (float(line[12]) == -1):
	    line[15] = -1
	#If this sample has a costEst above the goodness threshold,
	#this sample is classified as GOOD (1)
    	elif (float(line[15]) > goodness_threshold):
    	    line[15] = 1
	#If this sample has a positive costEst and is below the 
	#goodness threshold, this sample is classified as BAD (0)
	elif (float(line[15]) > 0):
	    line[15] = 0
	#If this sample has a negative costEst, it is classified 
	#as CRASH (-1)
	else:
	    line[15] = -1

output_filename = 'three_classes.data'

#Write the resulting dataset to a new output file
writer = csv.writer(open(output_filename,'w'))

i = -1

for line in lines:
    writer.writerow(line)


