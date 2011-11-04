require 'spec_helper'

describe Presenter do
  let(:model_name) { 'sign_up' }

  subject { Presenter.new(model_name) }

  it "handles the ActiveModel naming" do
    subject.class.model_name.singular.should == model_name
  end

  it "is an ActiveModel conversion" do
    subject.should_not be_persisted
    subject.to_model.should == subject
    subject.to_key.should be_nil
    subject.to_param.should be_nil
  end

  it "does not mind having a bunch of them" do
    Presenter.new("another_model_name").class.model_name
    # The result is that this should have no warning in the test output
  end

  it "sets attributes accessor per instance" do
    foo = Presenter.new("foo", :fields => [:foo])
    bar = Presenter.new("bar", :fields => [:bar])
    foo.should respond_to(:foo)
    bar.should respond_to(:bar)
    foo.should_not respond_to(:bar)
    bar.should_not respond_to(:foo)
  end
end

describe Presenter, 'validations' do
  let(:model_name) { 'sign_up' }
  let(:fields) { [:a, :b] }
  let(:failing_validator) do
    Class.new(ActiveModel::Validator) do
      def initialize(opts)
        @@attributes = opts[:attributes]
        super(opts)
      end

      def validate(record)
        record.errors[:base] << 'invalid'
      end

      def self.has_set_attributes_to?(attribs)
        @@attributes == attribs
      end
    end
  end
  let(:succeeding_validator) do
    Class.new(ActiveModel::Validator) do
      def validate(record)
        nil
      end
    end
  end
  let(:errors) { {:name => "can't be blank"} }

  it "is valid by default" do
    presenter = Presenter.new(model_name)
    presenter.should be_valid
    presenter.errors.should be_empty
  end

  it "runs validations as given" do
    presenter = Presenter.new(model_name,
                              :validator => failing_validator,
                              :fields => fields)
    presenter.should be_invalid
    presenter.errors.should_not be_empty
    failing_validator.should have_set_attributes_to(fields)
  end

  it "runs validations as given" do
    presenter = Presenter.new(model_name, :validator => succeeding_validator)
    presenter.should be_valid
    presenter.errors.should be_empty
  end

  it "adds errors" do
    presenter = Presenter.new(model_name)
    presenter.add_errors(errors)
    presenter.errors.should_not be_blank
    errors.each do |k,v|
      presenter.errors[k].should include(v)
    end
  end
end

describe Presenter, "enumerations" do
  let(:model_name) { 'sign_up' }
  subject do
    Presenter.
      new(model_name, :fields => [:a,:b]).
      with_params('a' => 'hello', 'b' => 'goodbye')
  end

  it "eaches" do
    subject.each do |k,v|
      fail unless [:a,:b].include?(k)
      v.should == 'hello' if k == :a
      v.should == 'goodbye' if k == :b
    end
  end

  it "is indexable" do
    subject[:a].should == 'hello'
    subject[:b].should == 'goodbye'
  end

  it "has at least #reject" do
    subject.reject {|k,v| k == :a}.should == [[:b, 'goodbye']]
  end
end
