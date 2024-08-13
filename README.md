# R-for-Behavioral-Data
This code is for cleaning and combining data files from behavioral test of multiple individuals. It runs to give you a summary with 1) total time spent of each behavior 2) time spent on each behavior of each 1-min span and 3) total attempts of doing each behavior for all the individuals. Before using it, make sure your data file is in the same pattern as the sample I provided, i.e. with start time and stop time, and END in the end. If you do not have the start time and stop time recorded separately, go for 'cowlogdata' by Kelly Jwallace. 

This code is inspired by kellyjwallace/cowlogdata

This code is written by Chenkun Jiang for the Garland lab in University of California-Riverside to analysis behavioral data of Forced Swim Experiment, on August 12th, 2024

# clflag
originally from https://github.com/kellyjwallace/cowlogdata

# cldataBehavior
inspired by 'cldata' from https://github.com/kellyjwallace/cowlogdata

Basic functions include:
  1. calculate the total time spent of a certain behavior
  2. total attempts of showing certain behavior

I modified it to: 
  1. fit our data file pattern
  2. add function to calculate the time of certain behavior in each minute of the whole experiment
  3. remove the parameter 'factor' (add it back if you need it)
