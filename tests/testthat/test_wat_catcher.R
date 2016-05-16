context('WatCatcher')

test_that('the initializer raises an error if a wattle host is not specified', {
  assign('wattle', list(), envir = globalenv())
  error = 'Something went wrong'
  class(error) = 'simpleError'
  expect_error(WatCatcher$new(error), 'No wattle host specified.', all=TRUE)
})

test_that('the initializer raises an error if a wattle environment is not specified', {
  assign('wattle', list(host = 'wattle.test.net'), envir = globalenv())
  error = 'Something went wrong'
  class(error) = 'simpleError'
  expect_error(WatCatcher$new(error), 'No wattle environment specified.', all=TRUE)
})

test_that('the initializer raises an error if a wattle app_name is not specified', {
  assign('wattle', list(host = 'wattle.test.net', app_env = 'test'), envir = globalenv())
  error = 'Something went wrong'
  class(error) = 'simpleError'
  expect_error(WatCatcher$new(error), 'No wattle app_name configuration specified.', all=TRUE)
})

test_that('wat_payload returns the right params', {
  assign('wattle', list(host = 'wattle.test.net', app_env = 'test', app_name = 'watcatchr_test'), envir = globalenv())
  payload = list()

  error = list(message = 'ahhh!')
  class(error) = 'simpleError'

  payload = WatCatcher$new(error)$wat_payload()

  expect_equal(payload$wat$message, 'ahhh!')
  expect_equal(payload$wat$error_class, 'simpleError')
  expect_equal(payload$wat$app_env, 'test')
  expect_equal(payload$wat$app_name, 'watcatchr_test')
  expect_equal(payload$wat$language, 'R')
  expect_equal(payload$wat$hostname, Sys.info()['nodename'])

  time = Sys.time()

  with_mock(
    sys.calls = function() 'Some lines of code',
    Sys.time = function() time,
    expect_equal(WatCatcher$new(error)$wat_payload()$wat$backtrace, 'Some lines of code'),
    expect_equal(WatCatcher$new(error)$wat_payload()$wat$captured_at, time)
  )
})

test_that('caught wats are posted to the wattle url', {
  error = simpleError(message = 'It broke')
  catcher = WatCatcher$new(error)

  assign('wattle', list(host = 'wattle.test.net', app_env = 'test', app_name = 'watcatchr_test'), envir = globalenv())

  assign('post_params', list(), envir = globalenv())

  # check that httr::POST is called with the right params
  with_mock(
    'httr::POST' = function(url, body, encode) { assign('post_params', list(url = url, body = body, encode = encode), envir = globalenv()) },
    sys.calls = function() c('Some lines','of code'),
    Sys.time = function() time,
    catcher$catch(),
    expect_equal(post_params$url, 'wattle.test.net/wats'),
    expect_equal(post_params$body, catcher$wat_payload()),
    expect_equal(post_params$encode, 'json'),
    .env = "base"
  )
})
