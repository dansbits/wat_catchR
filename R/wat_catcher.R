#' A reference class for posting wats to wattle
#'
#' @field exception The simpleError object for the raised exception
WatCatcher = setRefClass(
  'WatCatcher',
  fields = c('exception'),
  methods = list(
    initialize = function(e) {
      "Assign the exception field and validate that all necessary wattle params are present"
      exception <<- e
      check_for_params()
    },
    catch = function() {
      "Post the wat to the specified wattle host"
      httr::POST(full_host(), body = wat_payload(), encode = 'json')
    },
    full_host = function() {
      "Create the full path to post the wat to"
      paste0(wattle$host, "/wats")
    },
    check_for_params = function() {
      "Validate that all necessary params are present"
      if(is.null(wattle$host)) {
        stop('No wattle host specified.')
      }

      if(is.null(wattle$app_env)) {
        stop('No wattle environment specified.')
      }

      if(is.null(wattle$app_name)) {
        stop('No wattle app_name configuration specified.')
      }
    },
    wat_payload = function() {
      "Build the post payload to be sent to wattle"
      return(
        list(
          wat = list(
            message = exception$message,
            error_class = class(exception)[1],
            app_env = wattle$app_env,
            app_name = wattle$app_name,
            backtrace = paste(sys.calls(), collapse="\n"),
            language = 'R',
            hostname = Sys.info()['nodename'],
            captured_at = Sys.time()
          )
        )
      )
    }
  )
)
