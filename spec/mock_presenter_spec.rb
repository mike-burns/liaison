require 'spec_helper'

describe MockPresenter, 'params' do
  let(:params) {{'a' => 'one', 'b' => 'two'}}

  subject { MockPresenter.new(:params => params) }

  it "can access values using []" do
    params.each do |k,v|
      subject[k].should == v
    end
  end
end

describe MockPresenter, 'validations and errors' do
  let(:errors) {{ :account_name => "can't be blank" }}

  subject { MockPresenter.new(:valid => false, :errors => errors) }

  it "is invalid with errors" do
    subject.should_not be_valid
    subject.errors.should_not be_blank
    errors.each do |k,v|
      subject.errors[k].should include(v)
    end
  end
end

describe MockPresenter, 'adding errors' do
  let(:errors) {{ :account_name => "can't be blank" }}

  subject { MockPresenter.new }

  it "can add errors" do
    subject.add_errors(errors)

    subject.should_not be_valid
    subject.errors.should_not be_blank
    errors.each do |k,v|
      subject.errors[k].should include(v)
    end
    subject.should have_errors(errors)
  end

  it "has no errors by default" do
    subject.should be_valid
    subject.errors.should be_blank
    subject.should have_no_errors
  end
end
