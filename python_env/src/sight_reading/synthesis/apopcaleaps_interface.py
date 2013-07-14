import collections
import ConfigParser
import functools
import logging
import logging.config
import os
import re
import shutil
import subprocess

import sight_reading.conversion.file_conversion

MEASURES_RE = re.compile(r"""^(?P<preceding_rules>.*)(?P<measures_constraint>measures\((?P<num_measures>[0-9]+)\))(?P<following_rules>.*)$""")
GOAL_REDEF_RE = re.compile(r"""^(?P<pre_unspecified>.*(chaos\(chords,0\), ))(?P<post_unspecified>.*)$""")
MCHORD_RE = re.compile(r"""^(?P<constraint>mchord\((?P<measure_num>[0-9]+),(?P<chord>.*)\))$""")
BEAT_RE = re.compile(r"""^(?P<constraint>beat\((.+),(?P<measure_num>.+),(.+),(.+),(.+)\))$""")
NOTE_RE = re.compile(r"""^(?P<constraint>note\((.+),(?P<measure_num>.+),(.+),(.+),(.+)\))$""")
OCTAVE_RE = re.compile(r"""^(?P<constraint>octave\((.+),(?P<measure_num>.+),(.+),(.+),(.+)\))$""")
NEXT_BEAT_RE = re.compile(r"""^(?P<constraint>next_beat\((.+),(?P<measure_num>.+),(.+),(.+),(.+),(.+),(.+)\))$""")
THEME_BOUNDARY_RE = re.compile(r"""^(?P<constraint>theme_boundary\([a-z],[0-9][0-9]*\))$""")

GOAL_BACKUP_FN = 'goal_backup'
GOAL_FN = 'goal'
MIDI_FN = 'temp.midi'
RESULT_FN = 'temp.result'

_here = os.path.dirname(__file__)
runtime_path = _here.replace('src','runtime') + os.sep
logfile_path = os.path.join(runtime_path, 'logging.conf')
logging.config.fileConfig(logfile_path,
                          defaults={'this_dir': runtime_path})
LOG = logging.getLogger(__name__)

def _joinit(iterable, delimiter):
    r"""
    Auxiliary function used to intersperse an iterable with a
    delimiter.
           
    >>> _joinit([1, 2, 3, 4], 0)
    [1, 0, 2, 0, 3, 0, 4]
    """
    it = iter(iterable)
    yield next(it)
    for x in it:
        yield delimiter
        yield x


def _cleanup(gui_subpath, gui_path):
    r"""
    Clean up anything left over from previous runs.
    
    This involves restoring the goal to its original state and clearing
    the file containing results from a previous run.
    
    `gui_subpath` given a filename, returns the full
    path of that file in the APOPCALEAPS GUI folder.
    The other arguments are the full paths of the goal
    file and the result file.
    """
    shutil.copyfile(gui_subpath(GOAL_BACKUP_FN), gui_subpath(GOAL_FN))
    with open(gui_subpath(RESULT_FN), mode='w') as result_fh:
        pass
    for maybe_midi in os.listdir(gui_path):
        if '.midi' in maybe_midi:
            os.remove(gui_subpath(maybe_midi))


def _analyze_result_measure(gui_subpath, measure):
    r"""
    Analyze results stored about a previously generated measure.

    Specifically, this involves extracting constraints
    related to beats and notes from the results
    file and adding those which are relevant to the
    `measure`, which is the measure
    that is currently being 'fixed'.

    Chords must be extracted separately, because they
    cannot be considered in isolation.
    """
    accepted = []
    with open(gui_subpath(RESULT_FN)) as result_fh:
        for result_line in result_fh.readlines():
            if result_line.endswith(',\n'):
                result_line = result_line[0:-2]
            recent_matchers = [BEAT_RE, NEXT_BEAT_RE, NOTE_RE, OCTAVE_RE]
            constraint_match = None
            for matcher in recent_matchers:
                constraint_match = matcher.match(result_line)
                if constraint_match:
                    break
            if constraint_match:
                found_measure = int(constraint_match.group('measure_num'))
                if found_measure == measure:
                    constraint = constraint_match.group('constraint')
                    LOG.debug("appending constraint: " + constraint)
                    accepted.append(constraint)
    return accepted


def _analyze_global_result(gui_subpath, regex):
    r"""
    Analyze information provided by a particular regular expression.

    The regular expression must describe the form of a particular
    kind of constraint exactly and must encapsulate the entire
    constraint in a regular expression group named 'constraint'.

    This information is not meant to be specific to any measure.
    """
    accepted = []
    with open(gui_subpath(RESULT_FN)) as result_fh:
        for result_line in result_fh.readlines():
            constraint_match = regex.match(result_line[0:-2])
            if constraint_match:
                constraint = constraint_match.group('constraint')
                accepted.append(constraint)
    return accepted


def _construct_goal(gui_subpath, total_measures, initial=False,
                    unspecified=None):
    r"""
    Given a set of specifications, generate the APOPCALEAPS query
    representing the desired goal.
    """
    if initial:
        assert unspecified is None
        unspecified = [n for n in range(1, total_measures + 1)]
    else:
        assert len(unspecified) >= 1

    unspecified_constraints = ['unspecified_measure({0})'.format(n)\
                               for n in unspecified]
    # filter out any doubles
    duplicate_set = set()
    unspecified_constraints = [c for c in unspecified_constraints if
                               c not in duplicate_set and not duplicate_set.add(c)]

    # get the original backup goal
    with open(gui_subpath(GOAL_BACKUP_FN)) as backup_fh:
        for line in backup_fh.readlines():
            first_goal_match = MEASURES_RE.match(line)

    goal = first_goal_match.group('preceding_rules')
    goal += ', '.join(unspecified_constraints)
    goal += ', max_unspecified(0), '

    if initial:
        goal += 'initial, '
    else:
        specified = [n for n in range(1, total_measures + 1)\
                     if n not in unspecified] 
        chord_constraints = _analyze_global_result(gui_subpath, MCHORD_RE)
        LOG.debug('Chord info: {chord_constraints}'.format(**locals()))
        theme_constraints = _analyze_global_result(gui_subpath,
                                                   THEME_BOUNDARY_RE)
        LOG.debug('Theme info: {theme_constraints}'.format(**locals()))
        measure_constraints = [_analyze_result_measure(gui_subpath, spec)\
                               for spec in specified]
        global_constraints = chord_constraints + theme_constraints
        goal += ', '.join(global_constraints)
        goal += ', '
        for subset in measure_constraints:
            goal += ', '.join(subset)
            if len(subset) > 0:
                goal += ', '

    goal += first_goal_match.group('measures_constraint')
    return goal


def _process_goal(goal, gui_subpath, gui_path, name):
    r"""
    Transform the supplied goal into a composition.

    The composition will be output as a set of constraints,
    as a LilyPond file, a midi file. This
    function is blocking, because the goal should not change
    until these representations have been created.
    `name` determines the name of an additional midi copy that is
    output. Other files are unaffected by this and are used
    in the same way as under vanilla APOPCALEAPS. This is
    only for the sake of giving demonstrations and may be
    removed later.
    """
    new_goal_lines = ['\n', goal]
    LOG.debug('Executing: {0}'.format(goal))
    with open(gui_subpath(GOAL_FN), 'w') as goal_fh:
        goal_fh.writelines(new_goal_lines)
 
    midi_path = gui_subpath(MIDI_FN)
    # create a symbolic composition
    proc = subprocess.Popen(gui_subpath('handler2'), cwd=gui_path)
    proc.wait()
    # create .ly and .midi files
    proc = subprocess.Popen(gui_subpath('handler3'), cwd=gui_path)
    proc.wait()
    shutil.copy(midi_path, gui_subpath(name + '.midi'))


def _parse_themes(result_path):
    r"""
    Scan the results of an initial run of APOPCALEAPS.
    Return a data structure indicating which themes were created and to
    which measures they apply.

    Example output: {'u' : [(1,1), (2,2), (7,7)], 'a' : [(3,4), (5,6)]}
    This would indicate that the first, second and seventh measure are not
    considered part of any motif, but that the third and fourth measure form
    an instance of motif 'a', just like the fifth and sixth measure. In other
    words, the fifth and sixth measure form a repetition or a transposition
    of the third and fourth measure.

    Also note that undefined runs are always one measure long, so the tuples
    representing undefined runs have identical first and second elements.
    """
    result_dict = collections.defaultdict(list)
    with open(result_path) as result_fh:
        print(result_fh)
        for result_line in result_fh.readlines():
            theme_match = THEME_RE.match(result_line)
            if theme_match:
                theme = theme_match.group('theme')
                first_measure = int(theme_match.group('measure1'))
                second_measure = int(theme_match.group('measure2'))
                result_dict[theme].append((first_measure, second_measure))
    return result_dict


def _generate_with_test(gui_subpath, gui_path, result_path, total_measures, measure_num):
    r"""
    Generate a piece that satisfies supplied constraints.

    Specifically, recycle information from measures < `measure_num`.
    Also recycle information from duplicated measures >= `measure_num`
    if the last measure of the first repetition of the theme under
    consideration < `measure_num`.

    If a generated piece does not meet the supplied constraints,
    this function will try to generate the new measure again.
    Therefore, it will eventually return as long as the supplied constraints
    can be met.
    """
    # TODO incorporate "supplied constraints" mentioned in doc
    if measure_num == 1:
        goal = _construct_goal(gui_subpath, total_measures, initial=True)
        _process_goal(goal, gui_subpath, gui_path,
                      'measure-{measure_num}'.format(measure_num=measure_num))
    else:
        # thematic structure determines what to recycle
        # recycle measures >= `measure_num` if they are transpositions
        thematic_structure = _parse_themes(result_path)
        LOG.debug("Thematic structure is: {0}".format(thematic_structure))


def compose(music_path):
    r"""
    Given the location of the APOPCALEAPS 'music' folder, compose a new
    piece in an iterative fashion.
    """
    gui_path = os.path.join(music_path, 'gui')
    gui_subpath = functools.partial(os.path.join, gui_path)
    result_path = gui_subpath(RESULT_FN)
    total_measures = 13
    _cleanup(gui_subpath, gui_path)
    for measure_num in range(1, total_measures + 1):
        # auxiliary function checks which steps need to be taken
        _generate_with_test(gui_subpath, gui_path, result_path, total_measures, measure_num) 