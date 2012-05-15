#################################################################
#
# SuperCoder Processor
#
# Converts a set of CSV-formatted SuperCoder (http://hincapie.psych.purdue.edu/Splitscreen/index.html)
# subject coding files into an analyzeable dataset, with the following variables available for each
# coded trial: subject, trial number, trial length, total frames looking, center look frames,
# right look frames, left look frames, proportion of center looks to total looks, proportion left
# looks, and proportion right looks.
#
# INSTRUCTIONS:
#   1) Clean all your SuperCoder coded .rftd files (remove slashes and pre-/post-text).
#	2) Open each coding file in Excel and export as a CSV file.
#	3) Place all CSV coded files in a folder (default: csv-data) alongside this R script.
#	4) Load this R script, set working directory to directory containing script, and run
#      the process() function (with optional parameters), specified below).
# 
# (C) Copyright 2012, Brock Ferguson (brockferguson.com)
#
# SuperCoder (http://hincapie.psych.purdue.edu/Splitscreen/index.html) is a tool for coding infant looking time
# studies distributed by G. Hollich.
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#################################################################

process <- function (folder = 'csv-data', outputfile = 'processed.csv', frame_divisor = FALSE) {
  dataset <- data.frame(matrix(nrow=0, ncol=10))
  colnames(dataset) <- c('Subject', 'Trial', 'TrialLength', 'TotalLookFrames', 'Clooks', 'Rlooks', 'Llooks', 'Cprop', 'Rprop', 'Lprop')
  
  path <- paste(getwd(),'/',folder,sep="")
  files <- list.files(path=path, pattern=".csv", all.files=T, full.names=F)
  for (file in files) {
     cat(sprintf("Processing file: %s\n", file))
     
     # get subject from filename
     subject_name <- substr(file, 0, nchar(file) - 4)
     
     # generate the filepath
     filepath <- paste(folder, '/', file, sep ="")
     
     # read in the raw data file
     data <- read.csv(filepath, header = FALSE)
     colnames(data) <- c('Event','Start','Stop')
     
     # retrieve trial start times
     trials <- data[which(data$Event == 'B'), ]
     
     # retrieve trial stop times
     trial_ends <- data[which(data$Event == 'S'), ]
     
     # merge stop times into trial table
     trials["End"] <- trial_ends$Start
     rm(trial_ends)
     
     # iterate through trials
     for (i in 1:nrow(trials)) {
       trial <- trials[i,]
       
       # get all looks that started within trial
       r_looks <- data[which((data$Event == 'R') & (data$Start >= trial$Start) & (data$Stop <= trial$End)), ]
       r_looks$Total <- r_looks$Stop - r_looks$Start
       l_looks <- data[which((data$Event == 'L') & (data$Start >= trial$Start) & (data$Stop <= trial$End)), ]
       l_looks$Total <- l_looks$Stop - l_looks$Start
       c_looks <- data[which((data$Event == 'C') & (data$Start >= trial$Start) & (data$Stop <= trial$End)), ]
       c_looks$Total <- c_looks$Stop - c_looks$Start
       
       # calculate total looks
       c_frames <- sum(c_looks[, c("Total")])
       r_frames <- sum(r_looks[, c("Total")])
       l_frames <- sum(l_looks[, c("Total")])

       # make some calculations
       total_looks <- nrow(r_looks) + nrow(l_looks) + nrow(c_looks)
       total_trial_frames <- trial$End - trial$Start
       total_look_frames <- c_frames + r_frames + l_frames
       r_prop <- round(r_frames / total_look_frames, 6)
       l_prop <- round(l_frames / total_look_frames, 6)
       c_prop <- round(c_frames / total_look_frames, 6)
       
       # should we adjust by some frame count?
       # sometimes SuperCoder jumps through with frame counts of X (e.g., 5)
       # at a time
       if (frame_divisor != FALSE) {
         r_frames <- r_frames / frame_divisor
         l_frames <- l_frames / frame_divisor
         c_frames <- c_frames / frame_divisor
         total_look_frames <- total_look_frames / frame_divisor
         total_trial_frames <- total_trial_frames / frame_divisor
       }
       
       # insert into dataset
       new_row <- nrow(dataset) + 1
       
       dataset[new_row, 'Subject'] <- subject_name
       dataset[new_row, 'Trial'] < i
       dataset[new_row, 'TrialLength'] <- total_trial_frames
       dataset[new_row, 'TotalLookFrames'] <- total_look_frames
       if (length(c_frames) > 0) { dataset[new_row, 'Clooks'] <- c_frames }
       if (length(r_frames) > 0) { dataset[new_row, 'Rlooks'] <- r_frames }
       if (length(l_frames) > 0) { dataset[new_row, 'Llooks'] <- l_frames }
       if (length(c_prop) > 0) { dataset[new_row, 'Cprop'] <- c_prop }
       if (length(r_prop) > 0) { dataset[new_row, 'Rprop'] <- r_prop }
       if (length(l_prop) > 0) { dataset[new_row, 'Lprop'] <- l_prop }
     }
  }
  
  # write dataset
  write.csv(dataset, outputfile, row.names=FALSE)
}