Use this script to rewrite history! The script will tidy up your 
Mercurial Fast Downward history by
	- correcting incorrect author names in the commits
	- removing files from commits which take up a lot of space and are
	  not anymore necessary.
	  
Usage: run.sh [OLD FAST DOWNWARD REPO] [NEW FAST DOWNWARD REPO]

Files:
	- ReadMe.txt: this read me file
	- commit_size_delta.log: incremental size of commits, ordered from 
	    largest increase to lowest on the current master
	    repository.
	- downward_authormap.txt: rules for renaming authors in commits.
	- downward_filemap.txt: rules for including excluding files in
	    commits.
    - run.sh: script which starts the conversion
