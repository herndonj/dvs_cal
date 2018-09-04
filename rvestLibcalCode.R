# This code uses rvest to pull in the current list of DVS workshops
Sys.setenv(TZ="America/New_York")
library(rvest)
library(stringr)
library(lubridate)
library(tibble)
library(readr)
dvs_cal <- read_html("https://api3.libcal.com/api_events.php?iid=971&m=upc&cid=3819&c=&d=25858&l=50&target=_blank")

ntitle <- html_nodes(dvs_cal, ".s-lc-ea-ttit a")
ndate  <- html_nodes(dvs_cal, ".s-lc-ea-tdat td:nth-child(2)")
npresenter <- html_nodes(dvs_cal, ".s-lc-ea-tpre td:nth-child(2)")
ntime <- html_nodes(dvs_cal, ".s-lc-ea-ttim td:nth-child(2)")
nlocation <- html_nodes(dvs_cal, ".s-lc-ea-tloc td:nth-child(2)")
#The description nodes vary a great deal (everyone describes their
#workshop in different ways).  The code here is likely only going
#to pull the first paragraph.  Also, note that it has trouble 
#with people who put in heavily styled code chunks in their 
#descriptions
ndescription <- html_nodes(dvs_cal, "p:nth-child(1)")
nregistration <- html_nodes(dvs_cal, ".s-lc-ea-treg a")

title <- html_text(ntitle)
date <- html_text(ndate)
presenter <- html_text(npresenter)
time <- html_text(ntime)
location <- html_text(nlocation)
description <- html_text(ndescription)
registration <- html_attr(nregistration, "href")

#Time to clean up the node data
rm("ntitle","ndate","npresenter","ntime","nlocation","ndescription", "nregistration")

registration_link <- str_sub(registration,,-6)
workshop_id <- str_sub(registration_link,-7,-1)

##Let's make the dates actionable by creating r friendly dates
# first let's load lubridate (if not loaded already) to make things easier
#library(lubridate)
# create workshop_start datetime here
# code here creates a regular expression that pulls the starttime
date_without_day <- str_extract(date, "\\s.+")
date_without_day <- str_sub(date_without_day,2,)

#grab the time
start_time <- str_extract(time, "^\\d+\\:\\d+[apm]+")
end_time <-str_extract(time, "\\s+\\d+\\:\\d+[apm]+")
date_time_begin <- paste(date_without_day,start_time)
date_time_ends <- paste(date_without_day,end_time)
#nothing says 'date' like iso 8601
date <- mdy(date_without_day)

workshop_begins <- mdy_hm(date_time_begin, tz="America/New_York")
workshop_ends <- mdy_hm(date_time_ends, tz="America/New_York")
workshop_duration <- (workshop_ends - workshop_begins)
workshop_duration_minutes <- as.numeric(workshop_duration)*60

dvs_cal_tbl<- tibble(workshop_id,date,title,presenter,workshop_duration_minutes, workshop_begins,workshop_ends,description,registration_link, location)

# until I find a code example on how to get readr to export formatted times for EST outside of R...
#dvs_cal_tbl$start_time <- toString(dvs_cal_tbl$workshop_begins)
#dvs_cal_tbl$end_time <- toString(dvs_cal_tbl$workshop_ends)

#write_tsv(dvs_cal_tbl,path="/Users/joel/Dropbox/EDC/workshops/fall_2018/fall_2018_workshops.txt")

