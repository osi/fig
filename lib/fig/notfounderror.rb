module Fig
  # A (possibly remote) file that was looked for was not found.  This may or
  # may not actually be a problem; i.e. this may be the result of an existence
  # test.
  class NotFoundError < StandardError
  end
end
