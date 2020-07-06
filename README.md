This repository contains scripts to converts the official Fast Downward 
repository from Mercurial to Git. If the repository history was compatible 
with the Fast Downward development repository, then the converted repository
stays compatible.

Requirements:
  - Python 3.6+ (on Debian/Ubuntu: sudo apt install python3)
  - Python 3 "ensurepip" module (on Debian/Ubuntu: sudo apt install python3-venv)
  - Git

Usage:
    
    ./run-cleanup.sh [MERCURIAL REPOSITORY] [CLEANED MERCURIAL REPOSITORY]
    
    ./run-conversion.sh [MERCURIAL REPOSITORY] [CONVERTED GIT REPOSITORY]
    
	./run-cleanup-and-conversion.sh [MERCURIAL REPOSITORY] \
	                                [CLEANED MERCURIAL REPOSITORY] \
	                                [CONVERTED GIT REPOSITORY]

The scripts will automatically setup the required tools (a virtual
environment with compatible versions of Mercurial and the fast-export tool
https://github.com/frej/fast-export.git).

Cleanup Process:
- fix and unify author names in commit message
- fix typos in branch names
- remove large files from history that should not have been added
- Change commit message to follow our new convention (each commit shall
start with `[BRANCH NAME]`

Conversion Process:
- convert a mercurial repository with `fast-export`
- delete all git branches that belong to mercurial branches which have been
merged and closed
- remove empty commits
- run garbage collections


Let's rewrite history!
