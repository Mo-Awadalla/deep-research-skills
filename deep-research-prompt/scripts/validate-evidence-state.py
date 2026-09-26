#!/usr/bin/env python3
"""Check artifact structure only; does not approve research or certify truth."""
import sys
sys.dont_write_bytecode = True
from research_validation import main

if __name__ == '__main__':
    raise SystemExit(main(structure_only=True))
