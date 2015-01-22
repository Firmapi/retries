# Retries

[![Code Climate](https://codeclimate.com/github/Firmapi/retries/badges/gpa.svg)](https://codeclimate.com/github/Firmapi/retries)
[![Coverage Status](https://coveralls.io/repos/Firmapi/retries/badge.svg)](https://coveralls.io/r/Firmapi/retries)

Retries is a gem that provides a single function, `with_retries`, to evaluate a block several times in case of failure.

## Installation

This gem uses Ruby's keyword arugments, meaning version 2.1.0 or higher is required. Add this line to your application's Gemfile:

```ruby
gem "retries", git: "git@github.com:firmapi/retries.git"
```

And then execute:

    $ bundle

## Usage

Suppose we have some task we are trying to perform: `do_the_thing`. This might be a call to a third-party API
or a flaky service. Here's how you can try it three times before failing:

``` ruby
require "retries"
with_retries(max_tries: 3) { do_the_thing }
```

The block is passed a single parameter, `attempt_number`, which is the number of attempts that have been made
(starting at 1):

``` ruby
with_retries(max_tries: 3) do |attempt_number|
  puts "Trying to do the thing: attempt #{attempt_number}"
  do_the_thing
end
```

### Custom exceptions

By default `with_retries` recovers instances of `StandardError`. You'll likely want to make this more specific
to your use case. You may provide an exception class or an array of classes:

``` ruby
with_retries(max_tries: 3, recover: RestClient::Exception) { do_the_thing }
with_retries(max_tries: 3, recover: [RestClient::Unauthorized, RestClient::RequestFailed]) do
  do_the_thing
end
```

### Handlers

`with_retries` allows you to pass a custom handler that will be called each time before the block is retried.
The handler will be called with three arguments: `exception` (the recoverd exception), `attempt_number` (the
number of attempts that have been made thus far), and `total_delay` (the number of seconds since the start
of the time the block was first attempted, including all retries).

``` ruby
handler = Proc.new do |exception, attempt_number|
  puts "Handler saw a #{exception.class}; retry attempt #{attempt_number}."
end

with_retries(max_tries: 5, handler: handler, recover: [RuntimeError, ZeroDivisionError]) do |attempt|
  (1 / 0) if attempt == 3
  raise "hey!" if attempt < 5
end
```

This will print something like:

```
Handler saw a RuntimeError; retry attempt 1.
Handler saw a RuntimeError; retry attempt 2.
Handler saw a ZeroDivisionError; retry attempt 3.
Handler saw a RuntimeError; retry attempt 4.
```

## Development

To run the tests: first clone the repo, then

    $ bundle install
    $ bundle exec rake test

## License

Retries is released under the [MIT License](http://opensource.org/licenses/mit-license.php/).
