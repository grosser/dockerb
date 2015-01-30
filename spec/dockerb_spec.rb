require "spec_helper"

describe Dockerb do
  it "has a VERSION" do
    Dockerb::VERSION.should =~ /^[\.\da-z]+$/
  end
end
