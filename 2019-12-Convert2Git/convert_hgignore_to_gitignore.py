#! /usr/bin/env python
from __future__ import print_function

import argparse
import os
import re
import sys


def type_load_file(arg):
    if not os.path.isfile(arg):
        raise ValueError("The given argument is not a file: {}".format(arg))
    with open(arg, "r") as f:
        return f.read()


def type_ignore_map(arg):
    content = type_load_file(arg)
    ignore_map = {}
    for line in content.split("\n"):
        line = line.strip()
        if line == "" or line.startswith("#"):
            continue

        parts = line.split("=")
        if len(parts) != 2:
            raise ValueError("Ignore map entries have to be OLD=NEW")
        ignore_map[parts[0].strip()] = parts[1].strip()
    return ignore_map


parser = argparse.ArgumentParser(
    "Simple script to convert Mercurial's .hgignore to Git's .gitignore. This"
    "script can only convert only simple rules from regexp to glob syntax and "
    "otherwise relies on a user given file mapping old expressions in regexp "
    "syntax to new expressions in glob.")
parser.add_argument("hgignore", type=type_load_file)
parser.add_argument("--ignoremap", type=type_ignore_map, default=dict())

REGEX_SYNTAX_GLOB = re.compile(r"syntax:\s*glob")
REGEX_SYNTAX_REGEXP = re.compile(r"syntax:\s*regexp")
REGEX_ENDS_ON = re.compile(r"^\\(\.[a-zA-Z0-9]+)\$$")


def convert(hgignore, ignore_map):
    gitignore = ["# This file is automatically converted. Check all lines "
                 "for mistakes."]

    def add(pattern, old=None):
        if old:
            gitignore.append("# OLD: {}".format(old))
        gitignore.append(pattern)

    def add_todo(pattern):
        gitignore.append("# TODO: {}".format(pattern))

    glob_syntax = False
    for line in hgignore.split("\n"):
        line = line.strip()
        if line == "" or line.startswith("#"):
            add(line)
        elif REGEX_SYNTAX_GLOB.match(line):
            glob_syntax = True
        elif REGEX_SYNTAX_REGEXP.match(line):
            glob_syntax = False
        elif glob_syntax:
            add(line)
        else:
            # CONVERT regexp TO glob SYNTAX:
            # use user defined mapping
            if line in ignore_map:
                add(ignore_map[line])
            # simple *.suffix mappings
            elif REGEX_ENDS_ON.match(line):
                add("*{}".format(REGEX_ENDS_ON.match(line).group(1)), old=line)
            # unable to do any mapping
            else:
                add_todo(line)
    return "\n".join(gitignore)


if __name__ == "__main__":
    args = parser.parse_args(sys.argv[1:])
    print(convert(args.hgignore, args.ignoremap))
