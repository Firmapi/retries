module Kernel
  # Public : Runs the supplied code block and retries with an exponential
  # backoff.
  #
  # max_tries - The maximum number of times to runthe block.
  # delay - The delay between retries.
  # handler - If not `nil`, a `Proc` that will be called for each retry. It will
  #           be passed two arguments, `exception` (the rescued exception) and
  #           `attempt_number`.
  # recover - A specific exception class to recover or an array of classes.
  #
  def with_retries(max_tries: 3, delay: 0.8, handler: nil, recover: nil, &block)
    attempts = 0

    begin
      attempts += 1
      return block.call(attempts)

    rescue *Array(recover || StandardError) => exception
      raise exception if attempts >= max_tries

      handler && handler.call(exception, attempts)

      sleep delay
      retry
    end
  end
end
