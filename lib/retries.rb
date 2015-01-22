module Kernel
  # Public : Runs the supplied code block and retries with an exponential
  # backoff.
  #
  # max_tries - The maximum number of times to runthe block.
  # base_sleep_seconds - The starting delay between retries.
  # max_sleep_seconds - The maximum retries delay.
  # handler - If not `nil`, a `Proc` that will be called for each retry. It will
  #           be passed three arguments, `exception` (the rescued exception),
  #           `attempt_number`, and `total_delay` (seconds since start of first
  #           attempt).
  # recover - A specific exception class to recover or an array of classes.
  #
  def with_retries(max_tries: 3, base_sleep_seconds: 0.5, max_sleep_seconds: 1.0, handler: nil, recover: nil, &block)
    fail "max_tries must be greater than 0." unless max_tries > 0
    if base_sleep_seconds > max_sleep_seconds
      fail "base_sleep_seconds cannot be greater than :max_sleep_seconds."
    end

    exception_types_to_rescue = Array(recover || StandardError)
    fail "with_retries must be passed a block" unless block_given?

    attempts = 0
    start_time = Time.now
    begin
      attempts += 1
      return block.call(attempts)
    rescue *exception_types_to_rescue => exception
      raise exception if attempts >= max_tries
      handler.call(exception, attempts, Time.now - start_time) if handler
      # The sleep time is an exponentially-increasing function of base_sleep_seconds. But, it never exceeds
      # max_sleep_seconds.
      sleep_seconds = [base_sleep_seconds * (2**(attempts - 1)), max_sleep_seconds].min
      # Randomize to a random value in the range sleep_seconds/2 .. sleep_seconds
      sleep_seconds *= (0.5 * (1 + rand))
      # But never sleep less than base_sleep_seconds
      sleep_seconds = [base_sleep_seconds, sleep_seconds].max
      sleep sleep_seconds
      retry
    end
  end
end
