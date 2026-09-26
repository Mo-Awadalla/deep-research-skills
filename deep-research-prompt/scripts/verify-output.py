#!/usr/bin/env python3
"""Offline artifact gate; Python 3 and PyYAML required."""
import sys
sys.dont_write_bytecode = True
from research_validation import main

if __name__ == '__main__':
    raise SystemExit(main())
