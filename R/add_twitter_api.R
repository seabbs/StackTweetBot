#' Add a Twitter API Key
#'
#' @description Checks if a Twitter token is present at the supplied link and if not
#' gives instructions on how to create one.
#' @return Prints instructions to the command line.
#' @export
#'
#' @examples
#'
#' add_twitter_api()
add_twitter_api <- function() {

  if (Sys.getenv("TWITTER_PAT") %in% "") {
    message("A Twitter token is required to add posts to your twitter account. \n",
            "The first step is to create a twitter app, enter the following code for instructions. \n\n",
            'library(rtweet); vignette("auth") \n\n',
            "Follow the instructions to create a Twitter app. \n",
            "Copy the Consumer key and secret and create a token with the following code: \n\n",
            'twitter_token <- rtweet::create_token(app = "your_appname_here",
                                            consumer_key = "key_here",
                                            consumer_secret = "secret_here") \n\n',
            'Note if setting up the bot on a remote server do this locally and then upload \n\n',
            "Now save this token to your home directory with the following code: \n\n",
            'saveRDS(twitter_token, file = "~/twitter_token.rds"") \n\n',
            "Now save the token as an enviroment variable: \n\n",
            'Sys.setenv(TWITTER_PAT = "~/twitter_token.rds") \n\n',
            'If using Rstudio server you made need to manually add the TWITTER_PAT to the .Renviron.')
  }else{
    message("Your API key appears to be correctly stored as an enviroment variable.")
  }
  invisible()
}
