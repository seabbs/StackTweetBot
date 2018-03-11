
Tools to Make a Stack Overflow Twitter Bot
==========================================

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![Travis build status](https://travis-ci.org/seabbs/StackTweetBot.svg?branch=master)](https://travis-ci.org/seabbs/StackTweetBot) [![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/gfrebm0dpua1wmff?svg=true)](https://ci.appveyor.com/project/seabbs/stacktweetbot) [![Coverage status](https://codecov.io/gh/seabbs/StackTweetBot/branch/master/graph/badge.svg)](https://codecov.io/github/seabbs/StackTweetBot?branch=master)

The aim of this package is to allow for easy creation of Stack Overflow twitter bots. It provides a wrapper around functionality from [`rtweet`](http://rtweet.info/) and [`stackr`](https://github.com/dgrtwo/stackr). It was inspired by the [tidyverse tweets bot](https://github.com/wjakethompson/tidyverse-tweets/blob/master/tidyversetweets.R) by [Jake Thompson](https://www.wjakethompson.com/), from which large amounts of code has been adapted. For a working example of a bot built with this package see [h2o tweets bot](https://twitter.com/h2o_tweets), or [here](https://github.com/seabbs/h2o_tweets) for the code.

Installation
------------

Install the development version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("seabbs/StackTweetBot")
```

To schedule the bot you will either need to install `cronR` (if on Linux or Mac) with,

``` r
install.packages("cronR")
```

or taskscheduler (if on windows) with,

``` r
install.packages("taskscheduleR")
```

Quick start
-----------

1.  Load the package

``` r
library(StackTweetBot)
```

1.  Set up your bots [Twitter](https://twitter.com/) account.

2.  Set up access (or check you access) to the Twitter API with,

``` r
add_twitter_api()
#> A Twitter token is required to add posts to your twitter account. 
#> The first step is to create a twitter app, enter the following code for instructions. 
#> 
#> library(rtweet); vignette("auth") 
#> 
#> Follow the instructions to create a Twitter app. 
#> Copy the Consumer key and secret and create a token with the following code: 
#> 
#> twitter_token <- rtweet::create_token(app = "your_appname_here",
#>                                             consumer_key = "key_here",
#>                                             consumer_secret = "secret_here") 
#> 
#> Now save this token to your home directory with the following code: 
#> 
#> saveRDS(twitter_token, file = "~/twitter_token.rds"") 
#> 
#> Now save the token as an enviroment variable (replacing *** the location of your token): 
#> 
#> Sys.setenv(TWITTER_PAT = "~/twitter_token.rds")
```

1.  Set up access (or check access) to the Stack Overflow API. This is required to increase your daily rate limit from 300 to 10,000.

``` r
add_stack_api()
#> An API key is required to increase your daily rate limit from 300 to 10,000. 
#> The first step is to sign up for an API key here: https://stackapps.com/apps/oauth/register 
#> Now add it as a enviroment variable using the following code (replacing *** with your API key): 
#> 
#> Sys.setenv(STACK_EXCHANGE_KEY = "***")
```

1.  Set up and schedule the twitter bot, specifying the tags to look for and to exclude. Schedule the bot using `schedule = TRUE` and specifying the update time depending on your platform, see `?set_up_stack_tweet_bot` for details. To allow posting set `post = TRUE`, and to save the bot to a permanent directory (so that it will run after your R session has ended) specify the directory with `dir`.

``` r
set_up_stack_tweet_bot(extracted_tags = "ggplot2",
                       excluded_tags = "python",
                       time_window = 60,
                       add_process_fn = NULL, 
                       hashtags = "rstats",
                       run = TRUE, 
                       schedule = FALSE,
                       save = TRUE, 
                       post = FALSE,
                       dir = NULL,
                       verbose = TRUE,
                       frequency = "hourly")
#> No directory has been supplied for saving the twitter bot,
#>            defaulting to saving to the temporary directory. This directory will not be
#>              preserved once the r session has ended.
#> Saving the following code to: /tmp/Rtmp8s5awa/stack_tweet_bot.R
#> Code: 
#> 
#> library(StackTweetBot);
#> questions <- get_stack_questions(extracted_tags = 'ggplot2',
#>                                  excluded_tags = 'python',
#>                                  time_window = 60,
#>                                  add_process_fn = NULL);
#> 
#> posts <- post_stack_tweets(questions, hashtags = 'rstats',
#>                            post = FALSE);
#> Running bot..
#> library(StackTweetBot);
#> questions <- get_stack_questions(extracted_tags = 'ggplot2',
#>                                  excluded_tags = 'python',
#>                                  time_window = 60,
#>                                  add_process_fn = NULL);
#> 
#> posts <- post_stack_tweets(questions, hashtags = 'rstats',
#>                            post = FALSE);
```

1.  Check your bot is running.

``` r
## If using cronR on mac or linux
cronR::cron_ls()
## If using taskscheduleR on windows
taskscheduleR::taskscheduler_ls()
```

Additional Functionality
------------------------

File an issue [here](https://github.com/seabbs/StackTweetBot/issues) if there is a feature, that you think is missing from the package, or better yet submit a pull request!

Docker
------

This package has been developed in docker based on the `rocker/tidyverse` image, to access the development environment enter the following at the command line (with an active docker daemon running),

``` bash
docker pull seabbs/stacktweetbot
docker run -d -p 8787:8787 -p 1410:1410 -e USER=StackTweetBot -e PASSWORD=StackTweetBot --name StackTweetBot seabbs/stacktweetbot
```

The rstudio client can be accessed on port `8787` at `localhost` (or your machines ip). The default username isStackTweetBot and the default password is StackTweetBot. The docker file comes reloaded with `cronR` and therefore may also be used as a staging environment for your twitter bot.
