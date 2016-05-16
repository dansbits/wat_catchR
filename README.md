# watcatchR
watcatchR is an R client for the Wattle exception reporting service. Currently it provides nothing more than a class
for easily posting wats (errors). More information on Wattle can be found at: https://github.com/cconstantine/wattle

## Installation
```R
devtools::install_github('dansbits/wat_catchR')
```

## Setup
It is expected that a named list will be assigned to the variable 'wattle' in the global environment. The list should 
contain your wattle host name (host), app name (app_name) and app environment (app_env). Below is an example:

```R
assign(
  'wattle', 
  list(
    host = 'wattle.test.net',     # the host name of your wattle instance
    app_env = 'test',             # development, production or whatever is relevant to your scenario
    app_name = 'watcatchr_test'   # the name of your app or process
  ), 
  envir = globalenv()
)
```

## Usage
The WatCatcher should be used within an error rescue block. It is recommended that you use withCallingHalers instead of tryCatch.
This is because tryCatch does not allow access to the backtrace, which is used by the WatCatcher. 

Here is an example usage:

```R
withCallingHandlers(
  { 
    # the code that you want to run goes here. If there is an error, the error block will be called
    stop('R is on fire!') 
  },
  error = function(e) {
    WatCatcher$new(e)$catch()
  }
)
```
