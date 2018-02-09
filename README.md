
Get TB Data in R
================

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

Installation
------------

Install the development version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("seabbs/StackTweetBot")
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
docker run -d -p 8787:8787 -e USER=StackTweetBot -e PASSWORD=StackTweetBot --name StackTweetBot seabbs/stacktweetbot
```

The rstudio client can be accessed on port `8787` at `localhost` (or your machines ip). The default username is getTBinR and the default password is getTBinR.
