from __future__ import absolute_import
import argparse
import ConfigParser
import os
import pickle
import time

from itertools import product

from pykov import maximum_likelihood_probabilities

from .synthesis.apopcaleaps_interface import compose


def _get_dependencies(mode, key_mode):
    my_dir = os.path.dirname(os.path.realpath(__file__))
    runtime_dir = my_dir.replace('src','runtime')
    parameter_path = os.path.join(runtime_dir, 'parameters.ini')

    config = ConfigParser.ConfigParser()
    config.read(parameter_path)
    music_path = config.get('APOPCALEAPS', 'music_folder')
    data_path = config.get('Analysis', 'data_root')

    with open(os.path.join(data_path, 'pickled_r_percentiles_'+key_mode)) as fh:
        r_percentiles = pickle.load(fh)

    with open(os.path.join(data_path, 'pickled_rhythm')) as fh:
        r_chain = pickle.load(fh)
        _, P = maximum_likelihood_probabilities(r_chain)
        r_chain = P

    if mode == 'Temperley':
        m_percentiles_path = os.path.join(data_path, 'pickled_m_percentiles_temperley_'+key_mode)
        m_chain = None
    elif mode == 'Relative':
        m_chain_path = os.path.join(data_path, 'pickled_melody_relative')
        m_percentiles_path  = os.path.join(data_path, 'pickled_m_percentiles_relative')
    elif mode == 'Mixed':
        m_chain_path = os.path.join(data_path, 'pickled_melody_mixed')
        m_percentiles_path  = os.path.join(data_path, 'pickled_m_percentiles_mixed')
    with open(m_percentiles_path, 'rb') as fh:
        m_percentiles = pickle.load(fh)

    if mode != 'Temperley':
        with open(m_chain_path) as fh:
            m_chain = pickle.load(fh)
            _, P = maximum_likelihood_probabilities(m_chain)
            m_chain = P

    return music_path, r_chain, r_percentiles, m_chain, m_percentiles


def multi_compose(mode='Relative'):
    r"""
    Compose a melody for each combination of percentiles and key modes.
    
    Return the combination of percentile indices (starting at 0)
    and the execution time for each combination.

    Example output:
    [((0, 0, 'minor'), 1.0), ((0, 1, 'minor'), 2.0)]
    """
    from time import clock
    results = []
    for key_mode in ['major', 'minor']:
        music_path, r_chain, r_percentiles, m_chain, m_percentiles= _get_dependencies(mode, key_mode)
        r_sections = range(0, len(r_percentiles))
        m_sections = range(0, len(m_percentiles))
        all_combinations = product(r_sections, m_sections)
        for (section_r, section_m) in all_combinations:
            # only consider close percentiles
            if section_r in range(section_m - 1, section_m + 2):
                start_time = time.time()
                compose(music_path, r_chain, r_percentiles, section_r, m_chain, m_percentiles, section_m, mode, key_mode)
                end_time = time.time()
                results.append(((section_r, section_m, key_mode), int(end_time - start_time)))
    return results


def make_composition(mode, r_section, m_section, key_mode):
    music_path, r_chain, r_percentiles, m_chain, m_percentiles, = _get_dependencies(mode, key_mode)
    compose(music_path, r_chain, r_percentiles, r_section,
            m_chain, m_percentiles, m_section, mode, key_mode
            )

if __name__ == '__main__':

    arg_parser = argparse.ArgumentParser()
    explanation = "'Relative', 'Mixed' or 'Temperley' determines algorithm "\
                  "used to evaluate melodic difficulty." 
    arg_parser.add_argument('mode', help=explanation)
    arg_parser.add_argument('percentile_rhythm', help='0-indexed percentile')
    arg_parser.add_argument('percentile_melody', help='0-indexed percentile')
    arg_parser.add_argument('key_mode', help='major or minor')
    args = arg_parser.parse_args()
    mode = args.mode
    if mode:
        assert mode in ['Relative', 'Mixed', 'Temperley']
    else:
        mode = 'Relative'
    percentile_rhythm = int(args.percentile_rhythm)
    percentile_melody = int(args.percentile_melody)
    key_mode = args.key_mode

    make_composition(mode, percentile_rhythm, percentile_melody, key_mode)  # 0-indexed percentiles
