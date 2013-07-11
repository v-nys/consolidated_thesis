import mock
import unittest

import apopcaleaps_interface

class ParseThemesTest(unittest.TestCase):

    def test_regex_theme_theme(self):
        entry = 'theme(a,1,2)'
        match = apopcaleaps_interface.THEME_RE.match(entry)
        self.assertEquals(match.group('theme'), 'a') 

    def test_regex_theme_measure1(self):
        entry = 'theme(a,1,2)'
        match = apopcaleaps_interface.THEME_RE.match(entry)
        self.assertEquals(match.group('measure1'), '1')

    def test_regex_theme_measure2(self):
        entry = 'theme(a,1,2)'
        match = apopcaleaps_interface.THEME_RE.match(entry)
        self.assertEquals(match.group('measure2'), '2')

    @mock.patch('__builtin__.open')
    def test_parse_themes_okay(self, mock_open):
        lines = ['boo!\n', 'theme(a,1,2)\n', 'meh\n',
                 'theme(u,3,3)\n', 'theme(u,4,4)\n']
        mock_open.return_value.__enter__().readlines.return_value = lines
        print(mock_open.__enter__())
        themes = dict(apopcaleaps_interface._parse_themes('fakepath'))
        expected_themes = {'a' : [(1, 2)], 'u' : [(3, 3), (4, 4)]}
        self.assertEquals(themes, expected_themes) 


class GoalRedefinitionTest(unittest.TestCase):

    def test_regex_goal_redef_pre_unspecified(self):
        entry = "tempo(80), chaos(drums,0), chaos(chords,0), " +\
                "beat(chords,1,2,0.5,8), beat(chords,1,2,0,8)"
        match = apopcaleaps_interface.GOAL_REDEF_RE.match(entry)
        expected = "tempo(80), chaos(drums,0), chaos(chords,0), "
        self.assertEqual(match.group('pre_unspecified'), expected)

    def test_regex_goal_redef_post_unspecified(self):
        entry = "tempo(80), chaos(drums,0), chaos(chords,0), " +\
                "beat(chords,1,2,0.5,8), beat(chords,1,2,0,8)"
        match = apopcaleaps_interface.GOAL_REDEF_RE.match(entry)
        expected = "beat(chords,1,2,0.5,8), beat(chords,1,2,0,8)"
        self.assertEqual(match.group('post_unspecified'), expected)


class ResultMatcherTest(unittest.TestCase):

    def test_regex_beat_quotes_no_match(self):
        entry = "'beat(drums,12,1,0.75,16)'"
        match = apopcaleaps_interface.BEAT_RE.match(entry)
        self.assertIsNone(match)

    def test_regex_beat_comma_no_match(self):
        entry = "beat(drums,12,1,0.75,16),"
        match = apopcaleaps_interface.BEAT_RE.match(entry)
        self.assertIsNone(match)

    def test_regex_beat_comma_space_no_match(self):
        entry = "beat(drums,12,1,0.75,16), "
        match = apopcaleaps_interface.BEAT_RE.match(entry)
        self.assertIsNone(match)

    def test_regex_beat_just_constraint_match(self):
        entry = "beat(drums,12,1,0.75,16)"
        match = apopcaleaps_interface.BEAT_RE.match(entry)
        self.assertIsNotNone(match)

    def test_regex_octave_just_constraint_match(self):
        entry = "octave(bass,12,3,0,3)"
        match = apopcaleaps_interface.OCTAVE_RE.match(entry)
        self.assertIsNotNone(match)

    def test_regex_mchord_just_constraint_match(self):
        entry = "mchord(1,c)"
        match = apopcaleaps_interface.MCHORD_RE.match(entry)
        self.assertIsNotNone(match)

    def test_regex_note_just_constraint_match(self):
        entry = "note(drums,12,1,0,hh)"
        match = apopcaleaps_interface.NOTE_RE.match(entry)
        self.assertIsNotNone(match)

    def test_regex_next_beat_just_constraint_match(self):
        entry = "next_beat(drums,12,2,0,12,2,0.5)"
        match = apopcaleaps_interface.NEXT_BEAT_RE.match(entry)
        self.assertIsNotNone(match)


class GoalConstructionTest(unittest.TestCase):
    
    @mock.patch('__builtin__.open')
    def test_initial_goal(self, mock_open):
        from apopcaleaps_interface import _construct_goal
        mock_handle = mock_open().__enter__()
        mock_handle.readlines.return_value = ['key(minor), measures(3)']
        subpath = mock.MagicMock()
        expected = "key(minor), unspecified_measure(1), unspecified_measure(2)"
        expected += ", unspecified_measure(3), max_unspecified(0), initial"
        expected += ", measures(3)"
        self.assertEqual(_construct_goal(subpath, 3, initial=True), expected)

    @mock.patch('sight_reading.synthesis.apopcaleaps_interface._analyze_result_chords')
    @mock.patch('__builtin__.open')
    def test_structure_no_measures(self, mock_open, mock_analyze_chords):
        from apopcaleaps_interface import _construct_goal
        mock_handle = mock_open().__enter__()
        mock_handle.readlines.return_value = ['key(minor), measures(3)']
        mock_analyze_chords.return_value = ['mchord(1,c)',
                                            'mchord(2,am)',
                                            'mchord(3,c)']
        subpath = mock.MagicMock()
        expected = "key(minor), unspecified_measure(1), unspecified_measure(2)"
        expected += ", unspecified_measure(3), max_unspecified(0), "
        expected += "mchord(1,c), mchord(2,am), mchord(3,c), measures(3)"
        self.assertEqual(_construct_goal(subpath, 3, unspecified=range(1, 4)), expected)

    @mock.patch('sight_reading.synthesis.apopcaleaps_interface._analyze_result_measure')
    @mock.patch('sight_reading.synthesis.apopcaleaps_interface._analyze_result_chords')
    @mock.patch('__builtin__.open')
    def test_non_initial_goal(self, mock_open, mock_analyze_chords,
                              mock_analyze_measure):
        from apopcaleaps_interface import _construct_goal
        mock_handle = mock_open().__enter__()
        mock_handle.readlines.return_value = ['key(minor), measures(3)']
        subpath = mock.MagicMock()
        mock_analyze_chords.return_value = ['mchord(1,c)',
                                            'mchord(2,am)',
                                            'mchord(3,c)']
        mock_analyze_measure.side_effect = [[],
                                            ["next_beat(drums,3,2,0,3,2,0.5)"]]
        mock_subpath = mock.MagicMock()
        expected = "key(minor), unspecified_measure(2), max_unspecified(0), "
        expected += "mchord(1,c), mchord(2,am), mchord(3,c), "
        expected += "next_beat(drums,3,2,0,3,2,0.5), "
        expected += "measures(3)"
        self.assertEqual(_construct_goal(mock_subpath, 3, False, [2]),
                         expected)

        

class AnalyzeResultsTest(unittest.TestCase):

    @mock.patch('__builtin__.open')
    def test_analyze_result_chords(self, mock_open):
        from apopcaleaps_interface import _analyze_result_chords
        mock_open().__enter__().readlines.return_value =\
        ['mchord(1,c),\n', 'mchord(2,am),\n', 'blah', 'mchord(3,c),\n']
        expected = ['mchord(1,c)', 'mchord(2,am)', 'mchord(3,c)']
        mock_subpath = mock.MagicMock()
        self.assertEquals(_analyze_result_chords(mock_subpath), expected)

    @mock.patch('__builtin__.open')
    def test_analyze_result_measure(self, mock_open):
        from apopcaleaps_interface import _analyze_result_measure
        mock_open().__enter__().readlines.return_value =\
        ["next_beat(drums,2,2,0,2,2,0.5),\n",
         "next_beat(drums,3,2,0,3,2,0.5),\n",
         "next_beat(drums,2,3,0,2,3,0.5),\n"]
        mock_subpath = mock.MagicMock()
        self.assertEqual(_analyze_result_measure(mock_subpath, 2),
                         ["next_beat(drums,2,2,0,2,2,0.5)",
                          "next_beat(drums,2,3,0,2,3,0.5)"
                         ]
                        )

