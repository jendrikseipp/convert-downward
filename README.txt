This script converts the official Fast-Downward repository from
Mercurial to Git. If the repository history was compatible with the
Fast-Downward development repository, then the converted repository
stays compatible.

Requirements: python3.5+
Usage: ./run.sh [REPOSITORY TO CONVERT] [NEW REPOSITORY LOCATION]

The script will automatically setup the required tools (a virtual 
environment with the required Mercurial version and the fast-export 
tool by https://github.com/frej/fast-export.git).

Let's rewrite history!
