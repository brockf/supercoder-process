supercoder-process (R script)
================

Converts a set of CSV-formatted SuperCoder (http://hincapie.psych.purdue.edu/Splitscreen/index.html)
subject coding files into an analyzeable dataset, with the following variables available for each
coded trial: subject, trial number, trial length, total frames looking, center look frames,
right look frames, left look frames, proportion of center looks to total looks, proportion left
looks, and proportion right looks.

INSTRUCTIONS:
	
	1) Clean all your SuperCoder coded .rftd files (remove slashes and pre-/post-text).
	
	2) Open each coding file in Excel and export as a CSV file.
	
	3) Place all CSV coded files in a folder (default: csv-data) alongside this R script.
	
	4) Load this R script, set working directory to directory containing script, and run
      the process() function (with optional parameters), specified below).