# This awk script will replace each of the 'features'
# in file #2 with the values fount in file #1

BEGIN{
    FS=" "; 
    OFS="\t";
    FNUMBER=-1; 
    NUM_FEATURES=0;
    NUM_DUMMIES=3
}


# File 2: Title line
/^%/ {
    if(FNR==1) FNUMBER++;
    print $0
}

# Everything else
!/^%/ {
    if(FNR==1) FNUMBER++;

    if(FNUMBER == 0) {    
#	print "Recording Feature[",NUM_FEATURES"] = ", $0
	FEATURES[NUM_FEATURES] = $0
	NUM_FEATURES++;
    }
    else if(FNUMBER == 1) {
	# Output file
	for(i=1;i<=NF;i++){
	    if(i <= NUM_DUMMIES ||  i > NUM_DUMMIES+NUM_FEATURES)
		printf("%s\t",$i);
	    else {
		II=i-NUM_DUMMIES-1;
		printf("%s\t",FEATURES[II]);
	    }
	}
	printf("\n");
    }
}

END{}