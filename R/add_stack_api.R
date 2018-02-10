#' Add a StackOverflow API Key
#'
#' @description Checks if a StackOverflow API is present in the enviroment and if not
#' gives instructions on how to create one.
#' @return Prints instructions to the command line.
#' @export
#'
#' @examples
#'
#' add_stack_api()
add_stack_api <- function() {

  if (Sys.getenv("STACK_EXCHANGE_KEY") %in% "") {
    message("An API key is required to increase your daily rate limit from 300 to 10,000. \n",
            "The first step is to sign up for an API key here: https://stackapps.com/apps/oauth/register \n",
            "Now add it as a enviroment variable using the following code (replacing *** with your API key): \n\n",
            'Sys.setenv(STACK_EXCHANGE_KEY = "***")')
  }else{
    message("Your API key appears to be correctly stored as an enviroment variable.")
  }
invisible()
}
