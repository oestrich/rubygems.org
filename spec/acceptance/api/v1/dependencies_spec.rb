require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Dependencies" do
  get "/api/v1/dependencies" do
    parameter :gems, "List of comma separated gems you want dependencies for"

    let(:too_many_gems) { Array.new(251) { "a" }.join(",") }

    example "Getting dependencies - Requesting to many" do
      do_request(:gems => too_many_gems)

      response_body.should == "Too many gems to resolve, please request less than 250 gems"
      status.should == 413
    end

    example "Getting dependencies - Dependency missing" do
      do_request(:gems => "not_found")

      Marshal.load(response_body).should == []
      status.should == 200
    end

    example "Getting dependencies" do
      @versions = [Factory(:version), Factory(:version)].each do |version|
        Factory(:dependency, :version => version)
      end

      do_request(:gems => "RubyGem1")

      Marshal.load(response_body).should == Dependency.for(["RubyGem1"])
      status.should == 200
    end
  end
end
