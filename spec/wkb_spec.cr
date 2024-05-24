require "./spec_helper"

describe WKB do
  it "should have version" do
    WKB::VERSION.should_not be_nil
  end
end
