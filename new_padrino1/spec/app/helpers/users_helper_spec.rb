require 'spec_helper'

RSpec.describe "NewPadrino1::App::UsersHelper" do
  pending "add some examples to (or delete) #{__FILE__}" do
    let(:helpers){ Class.new }
    before { helpers.extend NewPadrino1::App::UsersHelper }
    subject { helpers }

    it "should return nil" do
      expect(subject.foo).to be_nil
    end
  end
end
