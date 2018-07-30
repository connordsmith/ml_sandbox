#!/usr/bin/env python

import re
import sys

def process_names_file (names_filename, comment_char='#', echo=False):
    zero_based_indices_to_field_names = dict();
    with open (names_filename) as names_file:
        for line in names_file:
            if echo:
                print 'Line: ' + line
            line = line.strip()
            if line.find(comment_char) == -1:
                data = line.split()
                one_based_index = int(data[0])
                field_name = data[1]
                zero_based_index = one_based_index - 1
                zero_based_indices_to_field_names[zero_based_index] = field_name
                if echo:
                    print 'Names file: ' + field_name + ', ' + str(zero_based_index)
    return zero_based_indices_to_field_names

def if_find_attribute_index_substitute_field_name (line, pattern, zero_based_indices_to_field_names):
    match = pattern.search(line)
    if not match:
        return (line, False)
    else:
        zero_based_attr_index = int(match.group(1))
        if zero_based_attr_index not in zero_based_indices_to_field_names:
            raise Exception('Index ' + str(zero_based_attr_index) + ' not in dict')
        field_name = zero_based_indices_to_field_names[zero_based_attr_index]
        line2 = line[0 : match.start(1)] + field_name + line[match.end(1) : len(line)]
        return if_find_attribute_index_substitute_field_name(line2, pattern, zero_based_indices_to_field_names)

def process_dot_file (dot_filename, zero_based_indices_to_field_names, echo=False):
    internal_node_pattern = re.compile('\(\d+\) (\d+) Cut=')
    leaf_node_pattern = re.compile('\(\d+\) Class=(\d+) ')
    discrete_node_pattern = re.compile('\(\d+\) (\d+)') # assumes greedy

    with open (dot_filename) as dot_file:
        for line in dot_file:
            line2, found = if_find_attribute_index_substitute_field_name (line, internal_node_pattern, zero_based_indices_to_field_names)
#            if not found:
#                line2, found = if_find_attribute_index_substitute_field_name (line, leaf_node_pattern, zero_based_indices_to_field_names)
            line2, found = if_find_attribute_index_substitute_field_name (line, discrete_node_pattern, zero_based_indices_to_field_names)
            print line2.rstrip()

def substitute_indices_with_field_names_in_dot_file (dot_filename, names_filename, comment_char='#', echo=False):
    zero_based_indices_to_field_names = process_names_file(names_filename, comment_char, False)
    if echo:
        print 'Got dict: ' + str(zero_based_indices_to_field_names)
    process_dot_file(dot_filename, zero_based_indices_to_field_names, echo)

echo = False
comment_char = '%'

args = sys.argv[1:]
num_args = len(args)
if num_args < 2:
    raise Exception('Invalid number of arguments')
else:
    dot_filename = args[0]
    names_filename = args[1]
    substitute_indices_with_field_names_in_dot_file(dot_filename, names_filename, comment_char, echo)
