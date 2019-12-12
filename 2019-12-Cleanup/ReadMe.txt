You this script to rewrite history! The script will tidy up your 
Mercurial Fast Downward history by
	- correcting incorrect author names in the commits
	- remove files from commits which take up a lot of space and are
	  not anymore necessary.
	  
Usage: run.sh [OLD FAST DOWNWARD REPO] [NEW FAST DOWNWARD REPO]

Files:
	- ReadMe.txt: this read me file
	- commit_size_delta.log: Incremental Fast Downward repository size
	    changes per commit on the converted master repository.
	- downward_authormap.txt: Rules for renaming authors in commits
	- downward_filemap.txt: Rules for which files to include/exclude in
	    commits.
    - run.sh: script which starts the conversion
