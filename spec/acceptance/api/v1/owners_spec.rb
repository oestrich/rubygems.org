require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Owners" do
  let(:user) { Factory(:user) }

  let(:headers) { { "HTTP_ACCEPT" => accept, "HTTP_AUTHORIZATION" => user.api_key } }
  let(:client) { RspecApiDocumentation::TestClient.new(self, :headers => headers) }

  let!(:rubygem) { Factory(:rubygem) }

  before do
    rubygem.ownerships.create(:user => user)
  end

  get "/api/v1/gems/:id/owners" do
    let(:id) { rubygem.name }

    context "json" do
      let(:accept) { "application/json" }

      example "Getting owners of a gem - JSON" do
        do_request

        response_body.should == rubygem.owners.to_json
        status.should == 200
      end

      example "Getting owners of a gem - Missing gem" do
        do_request(:id => "missing")

        response_body.should == "This rubygem could not be found."
        status.should == 404
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }

      example "Getting owners of a gem - XML" do
        do_request

        response_body.should == rubygem.owners.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }

      example "Getting owners of a gem - YAML" do
        do_request

        response_body.should == rubygem.owners.to_yaml
        status.should == 200
      end
    end
  end
end
