require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Api Keys" do
  let(:user) { Factory(:user) }

  let(:headers) { { "HTTP_ACCEPT" => accept, "HTTP_AUTHORIZATION" => "Basic #{ActiveSupport::Base64.encode64s("#{user.email}:password")}" } }
  let(:client) { RspecApiDocumentation::TestClient.new(self, :headers => headers) }

  get "/api/v1/api_key" do
    context "json" do
      let(:accept) { "application/json" }

      example "Getting your API Key - JSON" do
        do_request

        response_body.should == {"rubygems_api_key" => user.api_key}.to_json
        status.should == 200
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }

      example "Getting your API Key - XML" do
        do_request

        response_body.should == {"rubygems_api_key" => user.api_key}.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }

      example "Getting your API Key - YAML" do
        do_request

        response_body.should == {:rubygems_api_key => user.api_key}.to_yaml
        status.should == 200
      end
    end

    context "any" do
      let(:accept) { "text" }

      example "Getting your API Key - Any" do
        do_request

        response_body.should == user.api_key
        status.should == 200
      end
    end
  end
end
