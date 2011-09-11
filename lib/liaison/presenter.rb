require 'active_model'

class Presenter
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validate :instance_validations

  # Constructs a new Presenter object which can be passed to a form or
  # generally filled with values. It must take a model name, which is a string
  # that is the name of the model you are presenting. It can also take a
  # validator and fields.
  #
  #   Presenter.new('sign_up',
  #                 :fields => [:account_name, :email, :password],
  #                 :validator => SignUpValidator)
  def initialize(model_name, opts = {})
    @@model_name = model_name

    @validator = opts[:validator]
    @fields   = opts[:fields]

    self.class.send(:attr_accessor,*@fields) unless @fields.nil? || @fields.empty?
  end

  def instance_validations
    validates_with(@validator, :attributes => @fields) if @validator
  end

  def self.model_name # :nodoc:
    model_namer = Struct.new("ModelNamer", :name).new(@@model_name)
    ActiveModel::Name.new(model_namer)
  end

  def persisted? # :nodoc:
    false
  end

  # Set the params from the form using this.
  #
  #   @sign_up_presenter.with_params(params[:sign_up])
  def with_params(params = {})
    params.each {|k,v| self.send("#{k}=", v)}
    self
  end

  # Combine error messages from any ActiveModel object with the presenter's, so
  # they will show on the form.
  #
  #   @sign_up_presenter.add_errors(account.errors)
  #
  # You will probably use it like this:
  #
  #   class SignUp
  #     attr_accessor :presenter
  #     def save
  #       account = Account.new
  #       account.save.tap do |succeeded|
  #         presenter.add_errors(account.errors) unless succeeded
  #       end
  #     end
  #   end
  def add_errors(errs)
    errs.each {|k,v| errors.add(k,v)}
  end

  # Access individual values as if this were the CGI params hash.
  #
  #   @sign_up_presenter[:account_name]
  def [](key)
    to_hash[key]
  end

  # This is an instance of Enumerable, which means you can iterate over the
  # keys and values as set by the form.
  #
  #   @sign_up_presenter.each {|k,v| puts "the form set #{k} to #{v}" }
  def each(&block)
    to_hash.each(&block)
  end

  protected

  def to_hash
    @fields.inject({}) do |acc,field|
      acc[field] = send(field)
      acc
    end
  end
end
