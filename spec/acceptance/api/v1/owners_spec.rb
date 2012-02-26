require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Owners" do
  let!(:user) { Factory(:user) }
  let!(:user2) { Factory(:user) }

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

  post "/api/v1/gems/:id/owners" do
    parameter :email, "Owner email"

    required_parameters :email

    let(:accept) { "application/json" }
    let(:id) { rubygem.name }

    let(:email) { user2.email }

    example "Creating a new owner" do
      do_request

      response_body.should == "Owner added successfully."
      status.should == 200
    end

    example "Creating a new owner - Owner not found" do
      do_request(:email => "not@found.com")

      response_body.should == "Owner could not be found."
      status.should == 404
    end
  end

  delete "/api/v1/gems/:id/owners" do
    parameter :email, "Owner email"

    required_parameters :email

    let(:id) { rubygem.name }
    let(:accept) { "application/json" }
    let(:email) { user.email }

    example "Deleting an owner" do
      rubygem.ownerships.create(:user => user2)

      do_request

      response_body.should == "Owner removed successfully."
      status.should == 200
    end

    example "Deleting an owner - Last one" do
      do_request

      response_body.should == "Unable to remove owner."
      status.should == 403
    end

    example "Deleting an owner - Owner not found" do
      do_request(:email => "not@found.com")

      response_body.should == "Owner could not be found."
      status.should == 404
    end
  end
end
