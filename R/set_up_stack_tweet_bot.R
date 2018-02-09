#' Set Up a StackOverflow Twitter Bot
#'
#' @description Set up a StackOverflow twitter bot for a given list of tags, and excluded tags.
#' Job scheduling can be set up using either \code{cronR} or \code{taskscheduleR} depending
#' on the platform.
#' @param name Character string containing the bots name, defaults to "stack_tweet_bot".
#' @param dir Character string containing the directory into which to save the bot, defaults
#' to the temporary directory. Is not saved if \code{save = FALSE}.
#' @param run Logical, defaults to \code{TRUE}. Should the bot be run once saved?
#' @param schedule Logical, defaults to \code{TRUE}. Should the bot be schduled to run
#' using CRON?
#' @param save Logical, defaults to \code{TRUE}. Should the bot be saved.
#' @param ... Additional arguements to pass to \code{\link[cronR]{cron_add}} when
#' \code{schedule = TRUE}.The suggested frequency for the bot run is hourly,
#'  set this by passing \code{frequency = "hourly"}.
#'
#' @return A character string containing the twitter bot code.
#' @export
#' @seealso \code{\link[StackTweetBot]{get_stack_questions}} \code{\link[StackTweetBot]{post_stack_tweets}}
#' \code{\link[StackTweetBot]{add_twitter_api}} \code{\link[StackTweetBot]{add_stack_exchange_api}}
#' @importFrom glue glue
#' @examples
#'
#' set_up_stack_tweet_bot(run = FALSE, schedule = FALSE, save = FALSE)
#'
set_up_stack_tweet_bot <- function(name = "stack_tweet_bot",
                                   extracted_tags = NULL,
                                   excluded_tags = NULL,
                                   time_window = NULL,
                                   hashtags = NULL,
                                   Rprofile_path =".Rprofile",
                                   token_path = "twitter_token.rds",
                                   dir = NULL,
                                   run = TRUE,
                                   schedule = TRUE,
                                   save = TRUE,
                                   verbose = TRUE,
                                   ...) {

 if (is.null(dir) && save){
   message("No directory has been supplied for saving the twitter bot,
           defaulting to saving to the temporary directory")

   dir <- tempdir()
 }

  bot <- glue("
              library(StackTweetBot);
              get_stack_questions(extracted_tags = {extracted_tags},
                                  excluded_tags = {excluded_tags},
                                  time_window = {time_window},
                                  Rprofile_path = {Rprofile_path});
              post_stack_tweets(hashtags = {hashtags},
                                Rprofile_path = {Rprofile_path},
                                token_path = {token_path});
              ")

  bot_path <- file.path(dir, paste0(name, ".R"))

  if (save) {
    if (verbose) {
      message("Saving to following code to: ", bot_path)
      message("Code: \n\n", bot)
    }

    write_file(bot, path = bot_path)
  }else{
    message("Not saving bot. This means the bot cannot be run or scheduled.")

    if (run) {
      stop("Permission to save the bot is required in order to run it")
    }

    if (schedule) {
      stop("Permission to save the bot is required in order to schedule a job.")
    }
  }

  if (run) {
    if (verbose) {
      message("Running bot..")
    }
    source(bot_path)
  }

  if (schedule) {

    os <- Sys.info()[['sysname']]

    if (os %in% "Windows") {

      if (!library(taskscheduleR,
                   logical.return = T,
                   quietly = TRUE)) {
        stop("Please download it with, devtools::install_github('bnosac/taskscheduleR')")
      }

      if (verbose) {
        message("Starting taskschedule job for ", name, "bot. Check taskscheduler_ls() for a list of
            running jobs.")
      }

      taskscheduleR::taskscheduler_create(rscript = bot_path, ...)

    }else if (os %in% c("Linux", "Darwin")) {

      if (!library(cronR,
                   logical.return = T,
                   quietly = TRUE)) {
        stop("Please download it with, devtools::install_github('bnosac/cronR')")
      }

      if (verbose) {
        message("Starting cron job for ", name, "bot. Check cron_ls() for a list of
            running jobs.")
      }

      cronR::cron_add(bot_path, ...)
    }
  }


  return(bot)
}
