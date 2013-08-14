r"""
Script to display the different percentiles for each column in a list
of tuples. The exact percentile is supplied as a parameter.

For instance, if the supplied percentile is 25 and there are three elements
in each tuple, this script will first show the 25th, 50th, 75th and 100th
percentile of the first column; then it will show the same percentiles for
the second and third columns.

Also note that likelihoods are assumed to be log likelihoods.
As a result, the lowest likelihoods are in the lower percentiles.

This script assumes the supplied percentile is a divisor of 100.
"""

import argparse
import os
import pickle

from os.path import abspath, dirname, join

import scipy
from scipy.stats import spearmanr


HERE = dirname(abspath(__file__))


def show_percentiles(tuples):
    num_tuples = len(tuples)
    num_columns = len(tuples[0])
    for column in range(0, num_columns):
        ordered_tuples = sorted(tuples, key=lambda x: -x[column])
        # note: range is end-exclusive, so 101
        fractions = (p / 100.0 for p in range(percentile, 101, percentile))
        for fraction in fractions:
            index = int(round(fraction * num_tuples) - 1)
            value = ordered_tuples[index][column]
            output = 'Column {column}; Fraction {fraction}; Value {value}'.format(**locals())
            print(output)


def show_correlations(tuples):
    for column_a in range(0, len(tuples[0])):
        array_a = scipy.array([t[column_a] for t in tuples])
        for column_b in range(column_a + 1, len(tuples[0])):
            array_b = scipy.array([t[column_b] for t in tuples])
            spearman = spearmanr(array_a, array_b)
            message = 'Spearman between columns {a} and {b}: {s}'
            print(message.format(a=column_a, b=column_b, s=spearman))


if __name__ == '__main__':

    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('percentile')
    arg_parser.add_argument('tuples')
    args = arg_parser.parse_args()
    percentile = int(args.percentile)
    tuples_path = args.tuples
    assert 100 % percentile == 0

    with open(tuples_path, 'rb') as fh:
        tuples = pickle.load(fh)
    show_percentiles(tuples)
    show_correlations(tuples)
