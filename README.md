Liaison
=======

A Rails presenter class.

How to Use Liaison
------------------

Add this to your `Gemfile`:

    gem 'liaison'

Then run the bundler installer:

    bundle

You instantiate `Presenter` classes in your controllers, setting them as instance variables so they can be passed to the views. The `Presenter` class takes the model name as a string (`sign_up`, for example) then a hash of options. Currently supported options are `:fields`, a list of attributes on the presenter (`[:email, :password]`); and `:validator`, a class that knows how to validate the data (`SignUpValidator`).

An instance of the `Presenter` object is Hash-like: it implements the `Enumerable` module, which means it has an `#each` method among many others; it also has a `#[]` method, which you can use to access values just like with the CGI `params` hash.

The business logic classes (`SignUp` in the below example) live under `app/models` and are tested as normal, except instead of requiring `spec_helper` they can likely require just `rspec`.

Validator classes (`SignUpValidator` in the below example) live under `lib` and must either descend from `ActiveModel::Validator` or implement the same interface (`.kind`, `#kind`, `#validate` that takes a record, and a constructor that takes a hash of options). They are also unit tested like normal and can likely get away with just requiring `rspec` instead of `spec_helper`. Sadly, in order to hook into the `ActiveModel::Validations` framework, you must pass the validator class itself instead of an object (`SignUpValidator` vs `SignUpValidator.new`).

Tutorial and Thought Process
----------------------------

A major idea of [the presenter pattern](http://blog.jayfields.com/2007/03/rails-presenter-pattern.html) is to break off the business logic from the view object, letting the view logic be a dumb instance that knows how to get, set, and validate values. The business logic can then query the presenter object for the values as needed.

Look, here's an example business object:

    class SignUp
      attr_reader :user

      def initialize(presenter, account_builder = Account)
        @email        = presenter[:email]
        @password     = presenter[:password]
        @account_name = presenter[:account_name]
    
        @presenter       = presenter
        @account_builder = account_builder
      end
    
      def save
        if presenter.valid?
          account = account_builder.new(:name => account_name)
          @user = account.users.build(:email => email, :password => password)
          account.save.tap do |succeeded|
            presenter.add_errors(account.errors) unless succeeded
          end
        end
      end
    
      protected
    
      attr_accessor :email, :password, :account_name, :account_builder, :presenter
    end

It's just a class, which you can unit test as you please. A presenter object is passed in, then we pull the values out, make sure it's valid, and add errors to it as needed. This class does not deal directly with validations, state, or any of the ActiveModel nonsense.

Now you need to know how to use a `Presenter` object, so this is what the controller looks like:

    class SignupsController < ApplicationController
      def new
        @sign_up = presenter
      end
    
      def create
        @sign_up = presenter.with_params(params[:sign_up])
        db = SignUp.new(@sign_up)
    
        if db.save
          sign_in_as(db.user)
          redirect_to root_url
        else
          render :new
        end
      end
      
      protected
      
      def presenter
        Presenter.new('sign_up',
                      :fields => [:email, :password, :account_name],
                      :validator => SignUpValidator)
      end
    end

In our `new` action we simply set the `@sign_up` i-var to an instance of the `Presenter`. In `create` we use that `Presenter` instance, adding CGI params in. Then we pass that to the `SignUp` class defined above and it's all boring from there.

The `presenter` method in the above example produces a new `Presenter` instance. This instance has a model name (`sign_up`), fields the form will handle (`email`, `password`, and `account_name`), and a validator (`SignUpValidator`). The validator is any instance of `ActiveModel::Validator`, for example:

    class SignUpValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, "can't be blank") if value.blank?
      end
    end

You, the author of the business logic class, are in charge of checking in on these validations and errors. For example, before saving any objects you should check `Presenter#valid?`. And after you've saved something to the database you should add any errors onto the presenter using `Presenter#add_errors`.

Testing
-------

When writing your unit tests it'll be handy to have a mock presenter around, which is why we package a `MockPresenter` class for you to use. It gives you access to the `#have_errors` and `#have_no_errors` RSpec matchers.


    describe SignUp, 'invalid' do
      let(:params) { { :email => '',
                       :password => 'bar',
                       :account_name => 'baz' } }
      let(:errors) { { :email => "can't be blank" } }
      let(:presenter) do
        MockPresenter.new(:valid => false,
                          :params => params,
                          :errors => errors)
      end
      let(:account_builder) { MockAccount.new(:valid => true) }
    
      subject { SignUp.new(presenter, account_builder) }
    
      it "does not save the account or user" do
        subject.save.should be_false

        presenter.should have_errors(errors)
      end
    end

Contact
-------

Copyright 2011 [Mike Burns](http://mike-burns.com/).

Please [open a pull request on Github](https://github.com/mike-burns/liaison/pulls) as needed.
