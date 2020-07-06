This script converts the official Fast Downward repository from
Mercurial to Git. If the repository history was compatible with the
Fast Downward development repository, then the converted repository
stays compatible.

Requirements:
  - Python 3.5+ (on Debian/Ubuntu: sudo apt install python3)
  - Python 3 header files (on Debian/Ubuntu: sudo apt install python3-dev)
  - Python 3 "ensurepip" module (on Debian/Ubuntu: sudo apt install python3-venv)
  - Git

Usage:

	./run.sh [REPOSITORY TO CONVERT] [NEW REPOSITORY LOCATION]

The script will automatically setup the required tools (a virtual
environment with compatible versions of Mercurial and the fast-export tool
https://github.com/frej/fast-export.git).

Let's rewrite history!
