#' Get StackOverflow Questions For A List of Tags
#'
#' @description Extract StackOverflow questions for a given set of tags, exluding questions
#' related to an optional list of tags. This code is based on the [tidyverse tweets bot](https://github.com/wjakethompson/tidyverse-tweets/blob/master/tidyversetweets.R)
#' by [Jake Thompson](https://www.wjakethompson.com/).
#' @param extracted_tags A character vector of tags to extract questions for.
#' @param excluded_tags A character vector of tags to exclude questions from the
#' output.
#' @param time_window Numeric, the timewindow to extract questions for (in minutes.
#'  Defaults to 60 minutes. Note that a maximum of 100 questions are extracted by
#'  the StackOverflow api, if you expect your tags to have a high volume of questions
#'  reduce this. If using this function as part of a sheduled bot makes sure this time
#'  frame corresponds the frequency with which your bot is running.
#' @param add_process_fn A function. If additional munging or data extraction is required add
#' to a custom function and pass here. This function must except a dataframe as its first arguement
#' and return a dataframe. See the examples for details.
#' @return A list containing the title, creation date, link, and tags for StackOverflow
#' questions related to your selected tags.
#' @export
#' @importFrom dplyr select filter mutate arrange distinct
#' @importFrom tibble as_tibble
#' @importFrom purrr safely map map_dfr transpose map_lgl
#' @importFrom stackr stack_questions
#' @importFrom lubridate with_tz ymd_hms dminutes
#' @importFrom stringr str_replace_all
#' @examples
#'
#' ## Basic call
#' get_stack_questions(extracted_tags = "ggplot2",
#'                     excluded_tags = "plotly",
#'                     time_window = 120)
#'
#' ## Add additional processing step
#' library(dplyr)
#' add_process_fn <- function(df) {
#'       df %>%
#'       mutate(id = 1:n())
#' }
#'
#' get_stack_questions(extracted_tags = "ggplot2",
#'                     excluded_tags = "plotly",
#'                     time_window = 120,
#'                     add_process_fn = add_process_fn)
get_stack_questions <- function(extracted_tags = NULL,
                                excluded_tags = NULL,
                                time_window = 60,
                                add_process_fn = NULL) {

  creation_date <- NULL
  link <- NULL
  tags <- NULL
  title <- NULL
  desc <- NULL

  if (is.null(extracted_tags)) {
    stop("At least one tag is required by extracted tags")
  }

  if(!is.numeric(time_window)) {
    stop("time_window must be numeric")
  }

  if (is.null(add_process_fn)) {
    add_process_fn <- function(df) {
      df
    }
  }

  ## Make extracting stack questions safe
  safe_query <- purrr::safely(stackr::stack_questions)
  query_tag <- function(tag) {
    query <- safe_query(pagesize = 100, tagged = tag)
    return(query)
  }

  . <- NULL

  ##Extract questions from StackOverflow
  tidy_so <- map(extracted_tags, query_tag) %>%
    map_dfr(~(.$result %>% as_tibble())) %>%
    select(title, creation_date, link, tags) %>%
    mutate(
      title = str_replace_all(title, "&#39;", "'"),
      title = str_replace_all(title, "&quot;", '"'),
      title = str_replace_all(title, "&amp;&#160;", "& "),
      title = str_replace_all(title, "&gt;", ">"),
      title = str_replace_all(title, "&lt;", "<"),
      title = str_replace_all(title, "&amp;", "&")
    ) %>%
    distinct() %>%
    mutate(creation_date = lubridate::with_tz(creation_date, tz = Sys.timezone())) %>%
    arrange(desc(creation_date))

  if (!is.null(excluded_tags)) {
    tidy_so <- tidy_so %>%
      filter(!(map(excluded_tags, grepl, tags) %>%
                 transpose %>%
                 map(unlist) %>%
                 map_lgl(any)))
  }

  ## Run additional user specified processing, extract additional data etc...
  tidy_so <- tidy_so %>%
    add_process_fn()

  ## Get the current time
  cur_time <- ymd_hms(Sys.time(), tz = Sys.timezone())

  ## Filter questions by time frame
  update <-tidy_so %>%
    arrange(creation_date) %>%
    filter(creation_date > cur_time - dminutes(time_window)) %>%
    as.list()

  return(update)
}



