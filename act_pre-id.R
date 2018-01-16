# ACT Pre-ID File
# Evan Kramer
# 1/16/2018

library(tidyverse)
library(haven)
library(lubridate)

setwd("C:/Users/CA19130/Documents/Data/ACT/2018 Pre-ID")

# Create data file
p = 
    # Enrollment - all active grade 11 students
    read_csv("enrollment.csv") %>% 
                  arrange(STUDENT_KEY, desc(BEGIN_DATE)) %>% 
                  mutate_at(vars(ends_with("_DATE")), funs(dmy(.))) %>% 
                  group_by(STUDENT_KEY) %>% 
                  summarize_at(vars(FIRST_NAME:ASSIGNMENT), funs(first(.))) %>% 
    # Cohort - all active 2015 cohort members
    bind_rows(read_csv("cohort.csv") %>% 
                  mutate(ASSIGNMENT = as.integer(ASSIGNMENT))) %>% 
    group_by(STUDENT_KEY) %>% 
    summarize_at(vars(FIRST_NAME:ASSIGNMENT), funs(first(.))) %>%
    ungroup() %>% 
    # Crosswalk ACT HS codes
    left_join(readxl::read_excel("C:/Users/CA19130/Documents/Data/ACT/2018 Pre-ID/TN Crosswalk - 01-08-18.xlsx") %>% 
                  separate(`Local Site Code`, into = c("system", "school"), sep = " ") %>% 
                  mutate_at(vars(system, school), funs(as.integer(.))) %>% 
                  mutate(school = ifelse(system == 970, 140, school),
                         system = ifelse(`Organization Code` == 430034, 792, system),
                         school = ifelse(`Organization Code` == 430034, 8130, school),
                         school = ifelse(`Organization Code` == 430380, 53, school),
                         system = ifelse(`Organization Code` == 431220, 680, system),
                         school = ifelse(`Organization Code` == 431220, 27, school),
                         system = ifelse(`Organization Code` == 430297, 330, system),
                         school = ifelse(`Organization Code` == 430297, 280, school),
                         school = ifelse(`Organization Code` == 430377, 105, school),
                         school = ifelse(`Organization Code` == 431428, 8125, school)) %>% 
                  filter(!is.na(school) & !is.na(system)), by = c("PRIMARY_DISTRICT_ID" = "system", 
                                                                  "PRIMARY_SCHOOL_ID" = "school")) %>% 
    group_by(STUDENT_KEY) %>% 
    summarize_at(vars(FIRST_NAME:ASSIGNMENT, `Organization Code`), funs(first(.))) %>% 
    ungroup()

# Combine with DMR file
dmr = read_csv("K:/Research_Transfers/ACT Files/2018 Spring pre-ID/ACT_PreID_Final.csv") 

output = full_join(p, dmr, by = c("STUDENT_KEY" = "student_key")) %>% 
    transmute(`Student Code` = NA, 
              `Organization Code` = ifelse(is.na(Organization_Code), `Organization Code`, Organization_Code),
              `Last Name` = ifelse(is.na(last_name), str_sub(LAST_NAME, 1, 16), str_sub(last_name, 1, 16)),
              `First Name` = ifelse(is.na(first_name), str_sub(FIRST_NAME, 1, 12), str_sub(first_name, 1, 12)),
              `Middle Initial` = ifelse(is.na(middle_initial), str_sub(MIDDLE_NAME, 1, 1), middle_initial),
              `Grade` = ifelse(is.na(grade), ASSIGNMENT, grade),
              `Date of Birth` = ifelse(is.na(mdy(dob)), 
                                       str_c(ifelse(month(dmy(DATE_OF_BIRTH)) >= 10, month(dmy(DATE_OF_BIRTH)), str_c("0", month(dmy(DATE_OF_BIRTH)))), 
                                             ifelse(day(dmy(DATE_OF_BIRTH)) >= 10, day(dmy(DATE_OF_BIRTH)), str_c("0", day(dmy(DATE_OF_BIRTH)))), 
                                             year(dmy(DATE_OF_BIRTH)), sep = "/"), 
                                       str_c(ifelse(month(mdy(dob)) >= 10, month(mdy(dob)), str_c("0", month(mdy(dob)))),
                                             ifelse(day(mdy(dob)) >= 10, day(mdy(dob)), str_c("0", day(mdy(dob)))), 
                                             year(mdy(dob)), sep = "/")),
              `State Student ID` = STUDENT_KEY, `Test Code` = "mc", `Delivery Form` = Delivery_Format) %>% 
    arrange(`Organization Code`, `Delivery Form`) %>% 
    mutate(`Delivery Form` = dendextend::na_locf(`Delivery Form`))
    
    
# Output
write_csv(output, str_c("K:/Research_Transfers/ACT Files/2018 Spring pre-ID/ACT_pre-id_combined_EK_", 
                        str_replace_all(today(), "-", ""), ".csv"), na = "")