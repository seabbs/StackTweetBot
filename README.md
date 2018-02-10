
StackOverflow Tweet Bots
========================

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![Travis build status](https://travis-ci.org/seabbs/StackTweetBot.svg?branch=master)](https://travis-ci.org/seabbs/StackTweetBot) [![AppVeyor Build Status](https://ci.appveyor.com/seabbs/StackTweetBot)](https://ci.appveyor.com/api/projects/status/github//seabbs/StackTweetBot/?branch=master&svg=true) [![Coverage status](https://codecov.io/gh/seabbs/StackTweetBot/branch/master/graph/badge.svg)](https://codecov.io/github/seabbs/StackTweetBot?branch=master)

The aim of this package is to allow for easy creation of StackOverflow twitter bots. It provides a wrapper around functionality from [`rtweet`](http://rtweet.info/) and [`stackr`](https://github.com/dgrtwo/stackr). It was inspired by the [tidyverse tweets bot](https://github.com/wjakethompson/tidyverse-tweets/blob/master/tidyversetweets.R) \#' by [Jake Thompson](https://www.wjakethompson.com/), from which large amounts of code has been adapted. For a working example of a bot built with this package see [h2o tweets bot](https://twitter.com/h2o_tweets).

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

Additional Functionality
------------------------

File an issue [here](https://github.com/seabbs/StackTweetBot/issues) if there is a feature, or a dataset, that you think is missing from the package, or better yet submit a pull request!

Docker
------

This package has been developed in docker based on the `rocker/tidyverse` image, to access the development environment enter the following at the command line (with an active docker daemon running),

``` bash
docker pull seabbs/stacktweetbot
docker run -d -p 8787:8787 -p 1410:1410 -e USER=StackTweetBot -e PASSWORD=StackTweetBot --name StackTweetBot seabbs/stacktweetbot
```

The rstudio client can be accessed on port `8787` at `localhost` (or your machines ip). The default username is getTBinR and the default password is getTBinR. The docker file comes preloaded with `cronR` and therefore may also be used as a staging enviroment for your twitter bot.
