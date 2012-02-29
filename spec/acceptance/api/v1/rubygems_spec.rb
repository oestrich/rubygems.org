require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Gems" do
  let!(:user) { Factory(:user) }

  let(:headers) { { "HTTP_ACCEPT" => accept, "HTTP_AUTHORIZATION" => user.api_key } }
  let(:client) { RspecApiDocumentation::TestClient.new(self, :headers => headers) }

  let!(:rubygem) { Factory(:rubygem) }
  
  before do
    rubygem.ownerships.create(:user => user)
    Factory(:version, :rubygem => rubygem)
  end

  get "/api/v1/gems" do
    context "json" do
      let(:accept) { "application/json" }

      example "Getting all of your rubygems - JSON" do
        do_request

        response_body.should == user.rubygems.with_versions.to_json
        status.should == 200
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }

      example "Getting all of your rubygems - XML" do
        do_request

        response_body.should == user.rubygems.with_versions.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }

      example "Getting all of your rubygems - YAML" do
        do_request

        response_body.should == JSON.parse(user.rubygems.with_versions.to_json).to_yaml
        status.should == 200
      end
    end
  end

  get "/api/v1/gems/:id" do
    let(:id) { rubygem.name }
    let!(:rubygem2) { Factory(:rubygem, :name => "not_hosted") }

    context "json" do
      let(:accept) { "application/json" }

      example "Getting a gem - JSON" do
        do_request

        response_body.should == rubygem.to_json
        status.should == 200
      end

      example "Getting a gem - Not hosted" do
        do_request(:id => "not_hosted")

        response_body.should == "This gem does not exist."
        status.should == 404
      end

      example "Getting a gem - Not found" do
        do_request(:id => "not_found")

        response_body.should == "This rubygem could not be found."
        status.should == 404
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }

      example "Getting a gem - XML" do
        do_request

        response_body.should == rubygem.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }

      example "Getting a gem - YAML" do
        do_request

        response_body.should == JSON.parse(rubygem.to_json).to_yaml
        status.should == 200
      end
    end
  end
end
