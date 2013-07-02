import argparse

r"""
Auxiliary script to help in debugging APOPCALEAPS.

Takes the music.chrism file and adds unique debug output to every rule.
This way, the order of rule execution can be traced exactly.
"""

if __name__ == '__main__':
    argparser = argparse.ArgumentParser(description='Annotate a chrism file.')

