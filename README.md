This repository contains scripts for cleaning up Fast Downward repositories
and for converting them from Mercurial to Git. If the repository history was
compatible with the official Fast Downward Mercurial repository, then the converted
repository is compatible with the official Fast Downward Git repository.

Requirements:
  - Python 3.6+ (on Debian/Ubuntu: sudo apt install python3)
  - Python 3 "ensurepip" module (on Debian/Ubuntu: sudo apt install python3-venv)
  - Git

Usage:

  Run the script with the following command where [MERCURIAL REPOSITORY] is
  a path to the repository you want to convert, [CLEANED MERCURIAL REPOSITORY]
  is a location we can write an intermediate repository to, and
  [CONVERTED GIT REPOSITORY] is the location where we should write the
  resulting git repository. None of the paths may contain spaces.
  The intermediate cleaned Mercurial repository can be deleted after the
  conversion.

	./run-cleanup-and-conversion.sh [MERCURIAL REPOSITORY] \
                                    [CLEANED MERCURIAL REPOSITORY] \
                                    [CONVERTED GIT REPOSITORY]

  The conversion is done in two steps that can also be run individually:

    ./run-cleanup.sh [MERCURIAL REPOSITORY] [CLEANED MERCURIAL REPOSITORY]
    ./run-conversion.sh [CLEANED MERCURIAL REPOSITORY] [CONVERTED GIT REPOSITORY]

The scripts will automatically setup the required tools (a virtual
environment with compatible versions of Mercurial and the fast-export tool
https://github.com/frej/fast-export.git).

Warnings:
- Both scripts generate a lot of output on stdout and stderr. If you want
  to analyze it, better redirect it into files.
- The cleanup script generates repeated warnings about missing or invalid tags.
  These are caused by moved or broken tags and can be ignored.

Cleanup Process:
- fix and unify author names in commit message
- fix typos in branch names
- remove large files from history that should not have been added
- Change commit message to follow our new convention (each commit shall
start with "`[BRANCH NAME] `")

Conversion Process:
- convert a Mercurial repository with `fast-export`
- delete all Git branches that belong to Mercurial branches which have been
merged and closed
- remove empty commits
- run garbage collections


Let's rewrite history!
