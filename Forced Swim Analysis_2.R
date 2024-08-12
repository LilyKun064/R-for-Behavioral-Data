#made by: Chenkun Jiang on August 11th, 2024
#for behavioral tests

# Sample format of data file:
#   time    code              class
#   0.13    Behavior1 Start   1
#   5.37    Behavior1 End     1
#   5.37    Behavior2 Start   2
#   12.56   Behavior2 End     2
#   12.56   Behavior3 Start   3
#   70.54   END               0

#Measurements: 
# 1.BehaviorTime: total time of the behavior, 
# 2.Behavior1Min: time spent on the behavior within the first minute, similar for the rest of 1-min spans
# 3.BehaviorEntry1: first time starting to do the behavior, 
# 4.BehaviorBouts: total attempts of doing the behavior

library(dplyr)
library(stringr)
library(tidyr)

#set up path to file outside so you don't need to enter it every time
path = "D:/Forced Swim/Completed"

#put total minutes here
t = 6

#put your behavior codes here
behavior = c("ActiveSwim", "SlowPaddle", "Float", "Other")

#original function from github package "cowlogdata", check for files with no "END", with negative time differences, with fewer than 2 entries
#can be directly used if the package is installed
#if the package cannot be installed, copy the code
clflag <- function(pathtofile){
  file_list<-list.files(path = pathtofile, pattern = "*.csv")
  i<-1
  for (i in 1:length(file_list)){
    file<-read.csv(paste(pathtofile, file_list[i], sep= "/"))
    filename<-file_list[i]
    file<-as.data.frame(file)
    max<-nrow(file)
    if(file$code[max] != "END") {print(paste(filename, "WARNING: NO END"))}
    if(nrow(file) <5) {print(paste(filename, "WARNING: LESS THAN THREE ENTRIES"))}
    j<-1
    for (j in 1:nrow(file)){
      time_difference<-(as.numeric(file$time[j+1]))- (as.numeric(file$time[j]))
      if(is.na(time_difference) == FALSE & time_difference <0) {print(paste(filename, "WARNING: NEGATIVE TIME row", j ))}}}}

#utilizing the function
clflag(pathtofile = path)

#modified version of "cldata" from package "cowlogdata"
#cleaned extra white space caused by typos in the data file during behavioral code input
#the original function included parameters like "factors", which we do not need here, so commented out

cldataBehavior <- function(pathtofile, 
                           outputdataname, 
                           outputzonename, 
                           # factor = FALSE, 
                           # factorindex = NULL, 
                           # factorname = NULL, 
                           totalTimeinMin, 
                           behaviorCode) {
  file_list <- list.files(path = pathtofile, pattern = "*.csv")
  behavior_codes <- behaviorCode
  
  assign(outputzonename, behavior_codes, envir = .GlobalEnv)
  
  #we only want the mouseID as the first column, not the .csv extension there
  file_names <- gsub(".csv$", "", file_list)  
  data <- data.frame(MouseID = file_names)
  
  # if (factor) {
  #   data[[factorname]] <- sapply(file_list, function(f) {
  #     strsplit(gsub(".csv", "", f), "_")[[1]][factorindex]
  #   })
  # }
  
  for (behavior in behavior_codes) {
    data[[paste0(behavior, "Time")]] <- NA
    data[[paste0(behavior, "Entry1")]] <- NA
    data[[paste0(behavior, "Bouts")]] <- NA
    for (i in 1:totalTimeinMin) {
      data[[paste0(behavior, i, "Min")]] <- NA
    }
  }
  
  for (i in 1:length(file_list)) {
    file <- read.csv(file.path(pathtofile, file_list[i]))
    file$code <- str_replace_all(file$code, pattern = " ", "")
    
    if (nrow(file) > 0 && file$code[nrow(file)] == "END") {
      end_time <- file$time[nrow(file)]
      file <- file[-nrow(file), ]
    } else {
      end_time <- NA
    }
    
    overall_start_time <- file$time[1]
    
    for (behavior in behavior_codes) {
      start_code <- paste0(behavior, "Start")
      stop_code <- paste0(behavior, "Stop")
      
      start_times <- file$time[file$code == start_code]
      stop_times <- file$time[file$code == stop_code]
      
      # Ensure that the last behavior uses the last END time as the stop_time if necessary
      if (length(start_times) > length(stop_times)) {
        stop_times <- c(stop_times, end_time)
      } else if (length(stop_times) > length(start_times)) {
        stop_times <- stop_times[1:length(start_times)]
      }
      
      active_times <- stop_times - start_times
      active_times <- active_times[active_times > 0]
      total_active_time <- sum(active_times, na.rm = TRUE)
      
      data[[paste0(behavior, "Time")]][i] <- total_active_time
      data[[paste0(behavior, "Entry1")]][i] <- start_times[1]
      data[[paste0(behavior, "Bouts")]][i] <- length(start_times)
      
      if (!is.na(end_time)) {
        for (j in 1:totalTimeinMin) {
          segment_start <- overall_start_time + (j - 1) * 60
          segment_end <- segment_start + 60
          
          if (segment_start > end_time) break
          
          segment_start_time <- pmax(segment_start, start_times)
          segment_end_time <- pmin(segment_end, stop_times)
          
          segment_active_time <- sum(pmax(segment_end_time - segment_start_time, 0), na.rm = TRUE)
          data[[paste0(behavior, j, "Min")]][i] <- segment_active_time
        }
      } else {
        for (j in 1:totalTimeinMin) {
          data[[paste0(behavior, j, "Min")]][i] <- 0
        }
      }
    }
  }
  
  print(paste("NUMBER OF FILES:", length(file_list)))
  print(paste("NAME OF OUTPUT FILE:", outputdataname))
  print("BEHAVIORS:")
  print(behavior_codes)
  
  assign(outputdataname, data, envir = .GlobalEnv)
}

cldataBehavior(path,
               outputdataname = "Forced Swim Summary",
               outputzonename = "Behavior",
               # factor = FALSE,
               totalTimeinMin = t,
               behaviorCode = behavior)

# Replace NAs with desired values
`Forced Swim Summary` <- `Forced Swim Summary` %>%
  mutate(across(ends_with("Min"), ~ replace_na(., 0))) %>%
  mutate(across(ends_with("Time"), ~ replace_na(., 0))) %>%
  mutate(across(ends_with("Entry1"), ~ replace_na(., -9)))

# Write the output summary to a .csv file
write.csv(`Forced Swim Summary`, 
          "D:/Forced Swim/Forced_Swim_Summary.csv", 
          row.names = TRUE)