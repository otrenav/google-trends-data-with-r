##
## Google Trends Functions
##
## Omar Trejo
## February, 2017
##

get_google_trend <- function(string, start_date, end_date) {
    return(gtrends(
        string,
        start_date = start_date,
        end_date = end_date
    ))
}

google_trends_original <- function(csv_input,
                                   start_date,
                                   end_date,
                                   column = "Artist",
                                   csv_output = "results.csv") {
    data <- read.csv(csv_input)
    total <- nrow(data)
    results <- NULL
    counter <- 0
    for (string in data[, column]) {
        counter <- counter + 1
        print(paste(
            "Searching for: ", string,
            " (", counter, " / ", total, ")",
            sep = ""
        ))
        google_trend <- NULL
        tryCatch({
            google_trend <- get_google_trend(string, start_date, end_date)
        }, error = function(e) {
            print(paste(
                "There was an error for: ", string,
                " ... skipping.",
                sep = ""))
            print(e)
        })
        if (!is.null(google_trend)) {
            results <- rbind(results, google_trend$trend)
        }
    }
    write.csv(results, file = csv_output, row.names = FALSE)
    return(results)
}

google_trends_with_specific_waits <- function(csv_input,
                                              start_date,
                                              end_date,
                                              block_size = 10,
                                              wait_time = 60,
                                              column = "Artist",
                                              csv_output = "results.csv") {
    data <- read.csv(csv_input)
    total <- nrow(data)
    results <- NULL
    counter <- 0
    for (string in data[, column]) {
        counter <- counter + 1
        if (counter %% block_size == 0) {
            print("------------------------------")
            print(paste("Finished block: ", counter / block_size, sep = ""))
            print(paste("Waiting for ", wait_time, " seconds...", sep = ""))
            print("------------------------------")
            Sys.sleep(wait_time)
        }
        print(paste(
            "Searching for: ", string,
            " (", counter, " / ", total, ")",
            sep = ""
        ))
        google_trend <- NULL
        tryCatch({
            google_trend <- get_google_trend(string, start_date, end_date)
        }, error = function(e) {
            print(paste(
                "There was an error for: ", string,
                " ... skipping.",
                sep = ""))
            print(e)
        })
        if (!is.null(google_trend)) {
            results <- rbind(results, google_trend$trend)
        }
    }
    write.csv(results, file = csv_output, row.names = FALSE)
    return(results)
}

google_trends_modified <- function(csv_input,
                                    start_date,
                                    end_date,
                                    column = "Artist",
                                    csv_output = "results.csv") {
    data <- read.csv(csv_input)
    total <- nrow(data)
    results <- NULL
    seconds <- 10
    current <- 1
    ## for (string in data[, column]) {
    while (current < total) {
        if (seconds > 0) {
            wait(seconds)
        }
        print_search_info(data[current, column], current, total)
        google_trend <- NULL
        seconds <- tryCatch({
            google_trend <- get_google_trend(string, start_date, end_date)
        }, error = function(e) {
            print("[!] Quota limit detected.")
            return(increase_waiting_time(seconds))
        })
        if (!is.null(google_trend)) {
            seconds <- 10
            current <- current + 1
            results <- rbind(results, google_trend$trend)
        }
    }
    write.csv(results, file = csv_output, row.names = FALSE)
    return(results)
}

wait <- function(seconds) {
    print(paste("[+] Waiting for ", seconds, " seconds...", sep = ""))
    Sys.sleep(seconds)
}

print_search_info <- function(string, current, total) {
    print(paste(
        "[ ] Searching for: ", string,
        " (", current, " / ", total, ")",
        sep = ""
    ))
}

increase_waiting_time <- function(seconds) {
    if (seconds == 0) {
        seconds <- 1
    } else {
        seconds <- seconds * 2
    }
    return(seconds)
}
