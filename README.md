# Fast Downward Repository Converter

This repository contains scripts for cleaning up Fast Downward repositories
and for converting them from Mercurial to Git. If the repository history was
compatible with the official Fast Downward Mercurial repository, then the converted
repository is compatible with the official Fast Downward Git repository.

## Requirements
  - Python 3.6+ (on Debian/Ubuntu: sudo apt install python3)
  - Python 3 "ensurepip" module (on Debian/Ubuntu: sudo apt install python3-venv)
  - Git

## Usage
  Run the script with the following command where [MERCURIAL REPOSITORY] is a
  path to the repository you want to convert, [CLEANED MERCURIAL REPOSITORY] is
  a location where the intermediate cleaned up Mercurial repository will be
  written to, and [CONVERTED GIT REPOSITORY] is the location where the
  resulting Git repository will be written to. None of the paths may contain
  spaces. The intermediate cleaned up Mercurial repository can be deleted after
  the conversion.

    ./run-cleanup-and-conversion.sh [MERCURIAL REPOSITORY] \
                                    [CLEANED MERCURIAL REPOSITORY] \
                                    [CONVERTED GIT REPOSITORY]

  The conversion is done in two steps that can also be run individually:

    ./run-cleanup.sh [MERCURIAL REPOSITORY] [CLEANED MERCURIAL REPOSITORY]
    ./run-conversion.sh [CLEANED MERCURIAL REPOSITORY] [CONVERTED GIT REPOSITORY]

The scripts will automatically set up the required tools (a virtual
environment with compatible versions of Mercurial and the fast-export tool
https://github.com/frej/fast-export.git).

## Limitations
- Multiple Mercurial heads with the same branch name are not supported. If your
  repository has those, you will see
  `Error: repository has at least one unnamed head: hg rXXX`.

## Warnings
- Both scripts generate a lot of output on stdout and stderr. If you want
  to analyze it, better redirect it into files.
- The cleanup script generates repeated warnings about missing or invalid tags.
  These are caused by moved or broken tags and can be ignored.

## Details of the cleanup process
- fix and unify author names in commit message
- fix typos in branch names
- remove large files from history that should not have been added
- change commit message to follow the new convention which is to start with
"`[BRANCH NAME] `"

## Details of the conversion process
- convert a Mercurial repository to Git with `fast-export`
- delete all Git branches that belong to Mercurial branches which have been
  merged and closed
- remove empty commits
- run garbage collections


Let's rewrite history!
