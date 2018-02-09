

## Post tweets
pwalk(.l = update, .f = function(title, creation_date, link) {
  if (nchar(title) > 250) {
    trunc_points <- str_locate_all(title, " ") %>%
      .[[1]] %>%
      .[,1]
    trunc <- max(trunc_points[which(trunc_points < 247)]) - 1
    title <- paste0(str_sub(title, start = 1, end = trunc), "...")
  }

  tweet_text <- glue("{title} #tidyverse #rstats {link}")
  post_tweet(tweet_text, token = read_rds("~/.rtweet_token2.rds"))
})
