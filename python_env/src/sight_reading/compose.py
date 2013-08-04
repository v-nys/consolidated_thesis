import ConfigParser
import os
import pickle

from itertools import product

from pykov import maximum_likelihood_probabilities

from sight_reading.synthesis.apopcaleaps_interface import compose


def _get_dependencies(mode):
    my_dir = os.path.dirname(os.path.realpath(__file__))
    runtime_dir = my_dir.replace('src','runtime')
    parameter_path = os.path.join(runtime_dir, 'parameters.ini')

    config = ConfigParser.ConfigParser()
    config.read(parameter_path)
    music_path = config.get('APOPCALEAPS', 'music_folder')
    data_path = config.get('Analysis', 'data_root')

    if mode == 'Temperley':
        notelist_path = config.get('Temperley', 'notelist_path')
        melprob_path = config.get('Temperley', 'melprob_path')
    else:
        notelist_path = None
        melprob_path = None

    with open(os.path.join(data_path, 'pickled_rhythm')) as fh:
        r_chain = pickle.load(fh)
        _, P = maximum_likelihood_probabilities(r_chain)
        r_chain = P

    if mode == 'Temperley':
        m_percentiles_path = os.path.join(data_path, 'pickled_m_percentiles_temperley')
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

    return music_path, r_chain, r_percentiles, m_chain, m_percentiles, notelist_path, melprob_path


def multi_compose():
    r"""
    Compose a melody for each combination of percentiles.
    
    Return the combination of percentile indices (starting at 0)
    and the execution time for each combination.

    >>> multi_compose([-10.0], [-10.0, -20.0])  # NONDETERMINISTIC!
    [((0, 0), 1.0), ((0, 1), 1.0)]
    """
    from time import clock
    music_path, r_chain, r_percentiles, m_chain, m_percentiles, notelist_path, melprob_path = _get_dependencies(mode)
    r_sections = range(1, len(r_percentiles) + 1)
    m_sections = range(1, len(m_percentiles) + 1)
    results = []
    for (section_r, section_m) in product(r_sections, m_sections):
        start_time = clock()
        compose(music_path,
                r_chain, r_percentiles, section_r,
                m_chain, m_percentiles_m, section_m,
                mode, notelist_path, melprob_path)
        end_time = clock
        results.append(((section_r, section_m), end_time - start_time))
    return results


def make_composition(mode, r_section, m_section):
    music_path, r_chain, r_percentiles, m_chain, m_percentiles, notelist_path, melprob_path = _get_dependencies(mode)
    compose(music_path, r_chain, r_percentiles, r_section,
            m_chain, m_percentiles, m_section, mode,
            notelist_path, melprob_path)


if __name__ == '__main__':

    arg_parser = argparse.ArgumentParser()
    explanation = "'Relative', 'Mixed' or 'Temperley' determines algorithm "\
                  "used to evaluate melodic difficulty. Default: 'Relative'" 
    arg_parser.add_argument('--mode', help=explanation)
    args = arg_parser.parse_args()
    mode = args.mode
    if mode:
        assert mode in ['Relative', 'Mixed', 'Temperley']
    else:
        mode = 'Relative'

    make_composition(mode, 1, 1)
