#' Set Up a StackOverflow Twitter Bot
#'
#' @description Set up a StackOverflow twitter bot for a given list of tags, and excluded tags.
#' Job scheduling can be set up using either \code{cronR} or \code{taskscheduleR} depending
#' on your platform.
#' @param name Character string containing the bots name, defaults to "stack_tweet_bot".
#' @param dir Character string containing the directory into which to save the bot, defaults
#' to the temporary directory. Is not used if \code{save = FALSE}.
#' @param run Logical, defaults to \code{TRUE}. Should the bot be run once saved?
#' @param schedule Logical, defaults to \code{TRUE}. Should the bot be scheduled to run
#' using cronR/taskscheduleR? In order to schedule the bot \code{save} must be \code{TRUE}.
#' @param save Logical, defaults to \code{TRUE}. Should the bot be saved.
#' @param verbose Logical, defaults to \code{TRUE}. Should progress messages be
#' printed to the terminal.
#' @param ... Additional arguements to pass to \code{\link[cronR]{cron_add}} or \code{\link[taskscheduleR]{taskscheduler_create}}
#' when \code{schedule = TRUE}.The suggested frequency for the bot run is hourly,
#'  set this by passing \code{frequency = "hourly"} (\code{cronR}) or \code{schedule = "HOURLY"}  (\code{taskscheduleR}).
#'
#' @inheritParams post_stack_tweets
#' @inheritParams get_stack_questions
#'
#' @return A character string containing the twitter bot code.
#' @export
#' @seealso \code{\link[StackTweetBot]{get_stack_questions}} \code{\link[StackTweetBot]{post_stack_tweets}}
#' \code{\link[StackTweetBot]{add_twitter_api}} \code{\link[StackTweetBot]{add_stack_api}}
#' @importFrom glue glue
#' @importFrom readr write_file
#' @examples
#'
#'## Build and run twitter bot
#' set_up_stack_tweet_bot(extracted_tags = "ggplot2",
#'                        run = TRUE, schedule = FALSE,
#'                        save = TRUE, post = FALSE)
#' ## Sample bot output
#'posts
set_up_stack_tweet_bot <- function(name = "stack_tweet_bot",
                                   extracted_tags = NULL,
                                   excluded_tags = NULL,
                                   time_window = 60,
                                   add_process_fn = NULL,
                                   hashtags = "rstats",
                                   post = TRUE,
                                   dir = NULL,
                                   run = TRUE,
                                   schedule = TRUE,
                                   save = TRUE,
                                   verbose = TRUE,
                                   ...) {

 if (!is.null(add_process_fn)) {
   stop("Adding a processing function has not been implemented using set_up_stack_tweet_bot.
        If this is a requirement manual set up is required.")
 }
 if (is.null(dir)){

   if (verbose && save) {
     message("No directory has been supplied for saving the twitter bot,
           defaulting to saving to the temporary directory. This directory will not be
             preserved once the r session has ended.")
   }

   dir <- tempdir()
 }

  ## Format arguements prior to glueing
  prep_glue_char <- function(vec) {
    if (!is.null(vec) && length(vec) > 1) {
      paste0("c('", paste(vec, collapse = "', '"), "')")
    }else if (is.null(vec)){
      vec <- "NULL"
    }else if (is.character(vec)){
      vec <- paste0("'", vec, "'")
    }else{
      vec <- vec
    }
  }

  extracted_tags <- prep_glue_char(extracted_tags)
  excluded_tags <- prep_glue_char(excluded_tags)
  hashtags <- prep_glue_char(hashtags)
  time_window <- prep_glue_char(time_window)
  add_process_fn <- prep_glue_char(add_process_fn)

  bot <- glue("
              library(StackTweetBot);
              questions <- get_stack_questions(extracted_tags = {extracted_tags},
                                               excluded_tags = {excluded_tags},
                                               time_window = {time_window},
                                               add_process_fn = {add_process_fn});

              posts <- post_stack_tweets(questions, hashtags = {hashtags},
                                         post = {post});
              ")

  bot_path <- file.path(dir, paste0(name, ".R"))

  if (save) {
    if (verbose) {
      message("Saving the following code to: ", bot_path)
      message("Code: \n\n", bot)
    }

    write_file(bot, path = bot_path)
  }else{
    if (verbose) {
      message("Not saving bot. This means the bot cannot be run or scheduled.")
    }

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

      if (try(
        requireNamespace("taskscheduleR",
                         quietly = TRUE),
        silent = TRUE) %in% "try-error") {
        stop("tasksheduleR required for schdeduling. Please download it with, install.packages('taskscheduleR')")
      }

      if (verbose) {
        message("Starting taskschedule job for ", name, "bot. Check taskscheduler_ls() for a list of
            running jobs.")
      }

      ## Requires taskscheduleR
      taskscheduleR::taskscheduler_create(rscript = bot_path, ...)

    }else if (os %in% c("Linux", "Darwin")) {

      if (try(
        requireNamespace("cronR",
                         quietly = TRUE),
        silent = TRUE) %in% "try-error") {
        stop("cronR required for scheduling. Please download it with, install.packages('cronR')")
      }

      if (verbose) {
        message("Starting cron job for ", name, " bot. Check cron_ls() for a list of
            running jobs.")
      }

      ## Requires CRON
      bot_cmd <- cronR::cron_rscript(bot_path, log_append = TRUE)
      cronR::cron_add(bot_cmd, ...)
    }
  }

  return(bot)
}
