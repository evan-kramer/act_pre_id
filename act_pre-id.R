library(tidyverse)
library(haven)
library(lubridate)

setwd("C:/Users/CA19130/Documents/Data/ACT/2018 Pre-ID")
p = read_csv("enrollment.csv") %>% 
                  arrange(STUDENT_KEY, desc(BEGIN_DATE)) %>% 
                  mutate_at(vars(ends_with("_DATE")), funs(dmy(.))) %>% 
                  group_by(STUDENT_KEY) %>% 
                  summarize_at(vars(FIRST_NAME:ASSIGNMENT), funs(first(.))) %>% 
    bind_rows(read_csv("cohort.csv") %>% 
                  mutate(ASSIGNMENT = as.integer(ASSIGNMENT))) %>% 
    group_by(STUDENT_KEY) %>% 
    summarize_at(vars(FIRST_NAME:ASSIGNMENT), funs(first(.)))
    
write_csv(p, str_c("C:/Users/CA19130/Documents/Data/ACT/2018 Pre-ID/TN Pre-ID File_", 
                   str_replace_all(today(), "-", ""), ".csv"), na = "")