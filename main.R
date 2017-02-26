##
## Google Trends Main
##
## Omar Trejo
## February, 2017
##

library(gtrendsR)

source("./functions.R")

##
## Google credentials
## If you have 2Factor this won't work
##
user     <- ""
password <- ""

gconnect(user, password)

csv_input  <- "./artists.csv"
start_date <- "2015-01-01"
end_date   <- "2016-01-01"
block_size <- 10
wait_time  <- 60

## results <- google_trends_original(csv_input, start_date, end_date)
## results <- google_trends_modified(csv_input, start_date, end_date)

results <- google_trends_with_specific_waits(
    csv_input,
    start_date,
    end_date,
    block_size,
    wait_time
)
