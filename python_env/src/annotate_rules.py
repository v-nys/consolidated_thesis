r"""
Annotate a CHRiSM file for easier debugging.
Specifically, add a debug statement to each rule,
so that it becomes possible to follow program flow a posteriori.
"""

import argparse
import re

arg_parser = argparse.ArgumentParser(description="Annotate a CHRiSM file.")
arg_parser.add_argument('chrism')
args = arg_parser.parse_args()

# does not recognize a whole rule, but we only need the guard and body
# those come after ==> or <=> surrounded by whitespace
RULE_REGEX = re.compile(r'^(?P<pre>.*)(?P<glyph>\s(<=>|==>)\s)(?P<post>.*)$')

# end is indicated by a period
# followed by only whitespace and/or comments
# note that this also occurs outside rules
END_REGEX = re.compile(r'^(.*)\.(\s|(%.*))*$')

# guard is indicated by vertical bar
# unfortunately, so are lists
# so guard is bar not surrounded by square brackets
# make first bit ungreedy to account for one special Lilypond output rule...
GUARD_REGEX = re.compile(r'^(?P<pre>[^[]+?)(?P<glyph>\|)(?P<post>[^\]]+)$')

# number of the next annotation
annotation = 1

# whether we are currently processing a rule
# need this to prevent Prolog guards triggering guard syntax
rule = False

def process(line):
    global rule, annotation
    match = RULE_REGEX.match(line)
    if match:
        rule = True
        line = match.group('pre') + match.group('glyph') + "debugwriteln('DEBUG: autogen: {0}'), ".format(annotation) + match.group('post')
        annotation += 1
    match = GUARD_REGEX.match(line)
    if rule and match:
        line = match.group('pre') + match.group('glyph') + " debugwriteln('DEBUG: autogen: {0}'), ".format(annotation) + match.group('post')
        annotation += 1
    if END_REGEX.match(line):
        rule = False
    return line

if __name__ == '__main__':

    with open(args.chrism) as chrism_fh:
        # make sure to add rules before and after guards
        for line in chrism_fh.readlines():
            print(process(line).rstrip())
