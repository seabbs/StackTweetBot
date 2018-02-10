
#' Post A Tweet for Each Question
#'
#' @description Format and post StackOverflow questions as tweets, optionally returning them
#' as a formatted list. This code is based on the [tidyverse tweets bot](https://github.com/wjakethompson/tidyverse-tweets/blob/master/tidyversetweets.R)
#' by [Jake Thompson](https://www.wjakethompson.com/).
#' @param questions A list of questions to tweet as produced by \code{\link[StackTweetBot]{get_stack_questions}}.
#' @param hashtags A character vector of hashtags to attach to the tweet.
#' See \code{\link[StackTweetBot]{add_twitter_api}} for details.
#' @param post Logical, defaults to \code{TRUE}. Should the formatted tweets be published on
#' twitter, if \code{FALSE} then the tweets are instead returned as a list.
#'
#' @return Either nothing is returned or a formated list of tweets.
#' @export
#' @importFrom purrr map pmap walk
#' @importFrom glue glue
#' @importFrom stringr str_locate_all str_sub
#' @examples
#'
#'ggplot2_qs <-  get_stack_questions(extracted_tags = "ggplot2",
#'                                   excluded_tags = "plotly",
#'                                   time_window = 120)
#'
#'post_stack_tweets(ggplot2_qs, hashtags = "rstats", post = FALSE)
#'
post_stack_tweets <- function(questions = NULL,
                              hashtags = "rstats",
                              post = TRUE) {

  ## Generate hashtags
  if (is.null(hashtags)) {
    hashtags <- ""
  }else{
    hashtags <- map(hashtags, ~paste0("#", .)) %>%
      paste(collapse = " ")
  }

  title <- NULL
  creation_date <- NULL
  link <- NULL
  tags <- NULL

  ## Format tweets
  tweet_text <- pmap(.l = questions, .f = function(title, creation_date, link, tags, ...) {
    if (nchar(title) > 200) {
      trunc_points <- str_locate_all(title, " ") %>%
        .[[1]] %>%
        .[,1]
      trunc <- max(trunc_points[which(trunc_points < 197)]) - 1
      title <- paste0(str_sub(title, start = 1, end = trunc), "...")
    }

    tweet_text <- glue("{title} ({tags}) {hashtags} {link}")

    return(tweet_text)
  })

  if (post) {
    ## Post tweets
    walk(tweet_text, ~rtweet::post_tweet(.))
    return(invisible(NULL))

  }else{
    return(tweet_text)
  }
}


