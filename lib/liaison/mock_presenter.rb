class MockPresenter
  def initialize(opts = {})
    @valid = opts.delete(:valid) != false
    @fields = opts[:params]
    @errors = opts[:errors] || {}
  end

  def [](key)
    @fields[key]
  end

  def valid?
    @errors.empty? && @valid
  end

  def errors
    @errors
  end

  def add_errors(errs)
    errs.each {|k,v| @errors[k] = v}
  end

  def has_no_errors?
    @errors.empty?
  end

  def has_errors?(errors)
    errors.all? {|k,v| @errors[k] == v}
  end
end
