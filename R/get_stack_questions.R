

### Setup ----------------------------------------------------------------------
library(tidyverse)
library(lubridate)
library(stackr)
library(feedeR)
library(rtweet)
library(glue)
library(stringr)


### Query Stackoverflow API ----------------------------------------------------
safe_query <- safely(stack_questions)
query_tag <- function(tag) {
  query <- safe_query(pagesize = 100, tagged = tag)
  return(query)
}

extract_tags <- c("h2o")
excluded_tags <- c("python", "wefwe")

Sys.setenv(TZ = "GMT")
cur_time <- ymd_hms(Sys.time(), tz = Sys.timezone())

source("~/.Rprofile")

## Extract questions
tidy_so <- map(extract_tags, query_tag) %>%
  map_dfr(~(.$result %>% as.tibble())) %>%
  select(title, creation_date, link, tags) %>%
  filter(!(map(excluded_tags, grepl, tags) %>%
             transpose %>%
             map(unlist) %>%
             map_lgl(any))) %>%
  mutate(
    title = str_replace_all(title, "&#39;", "'"),
    title = str_replace_all(title, "&quot;", '"'),
    title = str_replace_all(title, "&amp;&#160;", "& "),
    title = str_replace_all(title, "&gt;", ">"),
    title = str_replace_all(title, "&lt;", "<"),
    title = str_replace_all(title, "&amp;", "&")
  ) %>%
  distinct() %>%
  mutate(creation_date = with_tz(creation_date, tz = "GMT")) %>%
  arrange(desc(creation_date))

## Filter questions by time
update <-tidy_so %>%
  arrange(creation_date) %>%
  filter(creation_date > cur_time - dminutes(60)) %>%
  as.list()

