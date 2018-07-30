#!/usr/bin/env python

import getopt, sys, re

# FIXME: Add an option to output the STRETCH/STRETCH/SIGMA stuff.


manpage = \
"""
NAME
     mk3-gather-raw-data.py - Gathers raw data for Mk2 Data sets

OPTIONS
      -h, --help
           Print man page and exit.
      -m, --mode
           Sets mode to "lighthouse", "showbest" or "viz"
      -r, --result-column
           Sets the data column in the input files to consider the "result"
      -a, --algorithm-columns
           Sets the list of comma-separated columns to consider as the "algorithm" choices
      -p, --problem-columns
           Sets the list of comma-separated columns to consider as the "problem" characteristics
      -g  --lighthouse-goodness
           Sets the "fraction of best to consider good" for lighthouse mode
"""
##########################################################################################

# problem_value -> (algorithm_key -> runtime)
problem_value_to_algorithm_to_runtime = dict()
# problem_value -> (algorithm_key -> ratio)
problem_value_to_algorithm_to_ratio = dict()
# where runtime is min over all algorithm keys with that stretch value.
problem_value_to_best_algorithm_and_runtime = dict()
# problem_value -> set of (algorithm_key, runtime)
problem_value_to_good_set = dict()

algorithms = set() # set of all algorithms we encounter

# FIXME: Stuff that should eventually be command-line args
dir_prefix="problem_"

##########################################################################################
def grepline(fname,grepstr):
    myline = ""
    for line in open(fname,"r"):
        if(grepstr in line):
            myline=line
            break
    return myline

def autogenerate_stretch():
    s=grepline("run_mk3.sh", "STRETCHES=(")
    ss = re.split(' *',s.replace('STRETCHES=(','').replace(')\n',''))
    return ss

def autogenerate_sigmas():
    s=grepline("run_mk3.sh", "SIGMAS=(")
    ss = re.split(' *',s.replace('SIGMAS=(','').replace(')\n',''))
    return ss

def autogenerate_column_labels(stretch_list, sigma_list):
    problem_value=[stretch_list[0], stretch_list[0],sigma_list[0]]
    data = read_file_header(problem_value,comment_char='%')
    return data

def comma_separated_string_to_int_list(csstr):
    s=csstr.split(',')
    for i in xrange(len(s)):
        s[i] = int(s[i])
    return s

##########################################################################################
def input_path (problem_desc):
    return "./"+dir_prefix + str(problem_desc) + "/muelu_sampling.dat"

def list2str (data, delimiter='_'):
    mystr = ""
    for i in xrange(0,len(data)):
        mystr += str(data[i])
        if i!=len(data)-1:
            mystr += delimiter
    return mystr

def str2list(mystring, delimiter='_'):
    return mystring.split(delimiter)

def make_key(data):
    num_problem_key_fields = len(problem_columns)
    num_algorithm_key_fields = len(algorithm_columns)
    # Next N entries make a tuple that uniquely identifies the "algorithm."
    if num_algorithm_key_fields == 1:
        algorithm_key = tuple([data[num_problem_key_fields]])
    else:
        algorithm_key = tuple(data[num_problem_key_fields:num_algorithm_key_fields+num_problem_key_fields])
    return algorithm_key

##########################################################################################          
def read_file_header(problem_data,comment_char='%'):
    problem_string = list2str(problem_data)
    data= []
    with open (input_path (problem_string)) as file:
        for line in file:
            if len (line) > 0:
                if line[0] == comment_char:
                    data = line.split()
                    break
    return data

##########################################################################################
def process_row(data,prefix=[]):
#    problem_value= list2str([data[0],data[1]],data[2])  # FIXME    
    if (len(prefix)==0):
        problem_value=list2str(data[0:len(problem_columns)])
    else:
        problem_value=list2str(prefix + data[0:len(problem_columns)])
    algorithm_key = make_key(data)
#    rrr = 1+len(algorithm_columns)
#    print 'data = ',data, "key = ",algorithm_key, "alg_cols =",algorithm_columns
 #   exit(0)
    
    runtime = data[-1]
    
    algorithms.add(algorithm_key)

    if problem_value not in problem_value_to_algorithm_to_runtime:
        problem_value_to_algorithm_to_runtime[problem_value] = dict()
        
    alg_to_runtime = problem_value_to_algorithm_to_runtime[problem_value]

    # If the same algorithm occurs more than once with the same
    # stretch value, just take the max run time.
    if algorithm_key in alg_to_runtime:
        runtime = max(alg_to_runtime[algorithm_key], runtime)
        
    alg_to_runtime[algorithm_key] = runtime
    #problem_value_to_algorithm_to_runtime[problem_value] = alg_to_runtime

    if problem_value in problem_value_to_best_algorithm_and_runtime:
        cur_best_alg, cur_opt_runtime = problem_value_to_best_algorithm_and_runtime[problem_value]
        if float(cur_opt_runtime) >= float(runtime):
#            print 'Updating best for '+problem_value+' to '+ str((algorithm_key, runtime)) + ' currbest = '+cur_opt_runtime
            problem_value_to_best_algorithm_and_runtime[problem_value] = (algorithm_key, runtime)
    else:
#        print 'Initializing best for '+problem_value+' to '+ str((algorithm_key, runtime))
        problem_value_to_best_algorithm_and_runtime[problem_value] = (algorithm_key, runtime)


##########################################################################################
def process_one_file (problem_data, desired_columns, comment_char='%', print_problem=False, echo_data=False):
    problem_value = list2str(problem_data)
    with open (input_path (problem_value)) as file:
        for line in file:
            if len (line) > 0:
                if line[0] != comment_char:
                    data = line.split()
                    if echo_data:
                        print ','.join(data)
                    desired_data = [str(data[index]) for index in desired_columns]
                    if print_problem:
                        process_row(desired_data,problem_data)
                    else:
                        process_row(desired_data)

##########################################################################################
def process_all_files (desired_columns, comment_char='%', print_problem=False, echo_data=False):
    for i in xrange(0,len(stretch_one_direction)):
        for j in xrange(i+1,len(stretch_one_direction)):
            for k in xrange(0,len(sigmas)):
                problem_data=[stretch_one_direction[i], stretch_one_direction[j], sigmas[k]]
                process_one_file(problem_data, desired_columns, comment_char, print_problem,echo_data)

  #  print problem_value_to_best_algorithm_and_runtime
#    exit(0)

##########################################################################################
def compute_good_algorithms(fraction_of_best_to_consider_good=0.8):
    for (problem_value, alg_to_runtime) in problem_value_to_algorithm_to_runtime.items():
        (best_alg, best_runtime) = problem_value_to_best_algorithm_and_runtime[problem_value]

        if problem_value not in problem_value_to_good_set:
            good_set = set()
        else:
            good_set = problem_value_to_good_set[problem_value]
        
        for (alg, runtime) in alg_to_runtime.items():
            ratio = float(best_runtime) / float(runtime)
            if ratio >= fraction_of_best_to_consider_good:
                good_set.add((alg, runtime))

        problem_value_to_good_set[problem_value] = good_set


##########################################################################################
def compute_algorithm_performance_fraction():
    for (problem_value, alg_to_runtime) in problem_value_to_algorithm_to_runtime.items():
        (best_alg, best_runtime) = problem_value_to_best_algorithm_and_runtime[problem_value]

        if problem_value not in problem_value_to_algorithm_to_ratio:
            problem_value_to_algorithm_to_ratio[problem_value] = dict()
        alg_to_ratio = problem_value_to_algorithm_to_ratio[problem_value]

        for (alg, runtime) in alg_to_runtime.items():
            ratio = float(best_runtime) / float(runtime)        
            alg_to_ratio[alg] = "%7.4f" % ratio


##########################################################################################
def print_line(problem_value, alg, runtime, in_class, print_runtime=False):
    problem_data = str2list(problem_value)
    if in_class:
        class_value = 1
    else:
        class_value = 0
    
    if print_runtime:
        print list2str(problem_data,',') + ',' + list2str(alg,',') + ',' + str(runtime) + ',' + str(class_value)
    else:
        print list2str(problem_data,',')  + ',' + list2str(alg,',') + ',' + str(class_value)


##########################################################################################
# "Lighthouse style" means: For each stretch value, classify the set
# of algorithm options as 1 if the corresponding run time is within
# the given fraction of the best run time for that stretch value, else
# as 0.
def postprocess_all_files_lighthouse_style(fraction_of_best_to_consider_good=0.8, print_runtime=False):
    compute_good_algorithms(fraction_of_best_to_consider_good)
    for (problem_value, alg_to_runtime) in problem_value_to_algorithm_to_runtime.items():
        good_set = problem_value_to_good_set[problem_value]
        for (alg, runtime) in alg_to_runtime.items():
            in_good_set = (alg, runtime) in good_set
            print_line(problem_value, alg, runtime, in_good_set, print_runtime)


##########################################################################################
# Viz style 
def postprocess_all_files_viz_style(print_runtime=False):
    compute_algorithm_performance_fraction()
    for (problem_value, alg_to_ratio) in problem_value_to_algorithm_to_ratio.items():
        for (alg, ratio) in alg_to_ratio.items():
            print list2str(str2list(problem_value),',')  + ',' + list2str(alg,',') + ',' + ratio


##########################################################################################
# "Showbest style" means: Map from stretch value, to corresponding
# algorithm option enum.
def postprocess_all_files_showbest_style(algenum_filename, comment_char, print_runtime=False):
    alg_enum = dict() # alg option -> integer enumeration
    enum_alg = dict() # integer enumeration -> alg option
    
    count = 0 # integer enumeration corresponding to the given alg
    for (problem_value, alg_to_runtime) in problem_value_to_algorithm_to_runtime.items():
        for alg in alg_to_runtime:
            if alg not in alg_enum:
                alg_enum[alg] = count
                enum_alg[count] = alg
                count = count + 1

    # Dump the enum_alg mapping to the given file
    with open(algenum_filename, 'w') as file:
        file.write(comment_char + " Showbest mapping from algorithm enum value to algorithm options.\n")
        my_column_names = ['AlgorithmEnum'] + [ column_names[i] for i in algorithm_columns ]
        file.write(comment_char + ','.join(my_column_names) + '\n')
        for enumval in xrange(0,count):
            line = str(enumval) + ',' + ','.join(enum_alg[enumval]) + '\n'
            file.write(line)
    
    # fraction=1 means only store the one best algorithm choice.
    compute_good_algorithms(1.0)
    for (problem_value, alg_to_runtime) in problem_value_to_algorithm_to_runtime.items():
        good_set = problem_value_to_good_set[problem_value] # should have 1 member
        for (alg, runtime) in good_set:
            string_to_print = list2str(str2list(problem_value),',') 
            if print_runtime:
                string_to_print = string_to_print + ',' + str(runtime)
            string_to_print = string_to_print + ',' + str(alg_enum[alg])
            print string_to_print

##########################################################################################
def preprocess_all_files_lighthouse_style(desired_columns, comment_char='%', print_runtime=False):
    desired_column_names = [column_names[index] for index in desired_columns]
    if not print_runtime:
        desired_column_names.remove(column_names[result_column])
    desired_column_names = desired_column_names + ["Good"]
    print comment_char + ','.join(desired_column_names)

##########################################################################################
def preprocess_all_files_viz_style(desired_columns, comment_char='%', print_runtime=False):
    desired_column_names = [column_names[index] for index in desired_columns]
    #if not print_runtime:
    #    desired_column_names.remove("SolveTime")
    q=",".join(desired_column_names)
    print comment_char + 'Stretch1, Stretch2, Sigma' + ', '.join(desired_column_names)



##########################################################################################
def preprocess_all_files_showbest_style(desired_columns, comment_char='%', print_runtime=False):
    desired_column_names = [column_names[index] for index in desired_columns]
    print comment_char + ','.join(desired_column_names) + ',AlgorithmEnum'


##########################################################################################
##########################################################################################
##########################################################################################

comment_char='%'

lighthouse_style=0
showbest_style=1
viz_style=2

#current_style = lighthouse_style
#current_style = showbest_style
current_style = viz_style

# Auto-extract the problem information list
stretch_one_direction = autogenerate_stretch()
sigmas = autogenerate_sigmas()

# Auto-extract column labels
column_names = autogenerate_column_labels(stretch_one_direction,sigmas)


# Parse command-line options
algorithm_columns = []
problem_columns = []
result_column = -2
lighthouse_goodness=0.8

try:
    opts, args = getopt.getopt(sys.argv[1:], "hm:r:a:p:g:", ["help", "mode","result-column","algorithm-columns","problem-columns","lighthouse-goodness"])
except getopt.GetoptError as err:
    print str(err)
    print manpage
    sys.exit(-1)

for o, a in opts:
    if o in ("-h", "--help"):
        print manpage
        sys.exit()
    elif o in ("-m", "--mode"):
        mode = a
    elif o in ("-r", "--result-column"):
        result_column = int(a)
    elif o in ("-a", "--algorithm-columns"):
        algorithm_columns = comma_separated_string_to_int_list(a)
    elif o in ("-p", "--problem-columns"):
        problem_columns =  comma_separated_string_to_int_list(a)
    elif o in ("-g", "--lighthouse-goodness"):
        lighthouse_goodness = float(a)
    else:
        assert False, "unhandled option"

if mode == "lighthouse":
    current_style = lighthouse_style
elif mode == "showbest":
    current_style = showbest_style
elif mode == "viz":
    current_style = viz_style
else:
    print str('Invalid mode \''+mode+'\'')
    print manpage
    sys.exit(-1)

if len(algorithm_columns) == 0 or len(problem_columns) == 0 or result_column < -1:
    print "Please specify columns"
    print manpage
    sys.exit(-1)

columns_we_want = problem_columns[:] + algorithm_columns[:] + [result_column]
#print "columns_we_want =",columns_we_want

##################

print_runtime=False
print_problem=False
if current_style == lighthouse_style:
    preprocess_all_files_lighthouse_style (columns_we_want, comment_char, print_runtime)
elif current_style == viz_style:
    preprocess_all_files_viz_style (columns_we_want, comment_char, print_runtime)
    print_problem=True
else:
    preprocess_all_files_showbest_style (problem_columns,comment_char, print_runtime)    

#echo_data=True
echo_data=False
process_all_files (columns_we_want, comment_char, print_problem, echo_data)


do_postprocess=True
#do_postprocess=False
if do_postprocess: 
    if current_style == lighthouse_style:
       # postprocess_all_files_lighthouse_style(lighthouse_goodness, print_runtime)
    elif current_style == viz_style:
        postprocess_all_files_viz_style(print_runtime)
    else:
        algenum_filename='./stretch-showbest-algenum.txt'
        postprocess_all_files_showbest_style(algenum_filename, comment_char, print_runtime)
