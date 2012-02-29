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

      example_request "Getting owners of a gem - JSON" do
        response_body.should == rubygem.owners.to_json
        status.should == 200
      end

      example_request "Getting owners of a gem - Missing gem", :id => "missing" do
        response_body.should == "This rubygem could not be found."
        status.should == 404
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }

      example_request "Getting owners of a gem - XML" do
        response_body.should == rubygem.owners.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }

      example_request "Getting owners of a gem - YAML" do
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

    example_request "Creating a new owner" do
      response_body.should == "Owner added successfully."
      status.should == 200
    end

    example_request "Creating a new owner - Owner not found", :email => "not@found.com" do
      response_body.should == "Owner could not be found."
      status.should == 404
    end

    context "no permission" do
      before do
        rubygem.ownerships.create(:user => Factory(:user))
        rubygem.ownerships.find_by_user_id(user.id).destroy
      end

      example_request "Creating a new owner - No permission" do
        response_body.should == "You do not have permission to manage this gem."
        status.should == 401
      end
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

    example_request "Deleting an owner - Last one" do
      response_body.should == "Unable to remove owner."
      status.should == 403
    end

    example_request "Deleting an owner - Owner not found", :email => "not@found.com" do
      response_body.should == "Owner could not be found."
      status.should == 404
    end

    context "no permission" do
      before do
        rubygem.ownerships.create(:user => Factory(:user))
        rubygem.ownerships.find_by_user_id(user.id).destroy
      end

      example_request "Deleting an owner - No permission" do
        response_body.should == "You do not have permission to manage this gem."
        status.should == 401
      end
    end
  end

  get "/api/v1/owners/:handle/gems" do
    let(:handle) { user.handle }

    context "json" do
      let(:accept) { "application/json" }

      example_request "Getting a user's gems - JSON" do
        response_body.should == user.rubygems.with_versions.to_json
        status.should == 200
      end

      example_request "Getting a user's gems - Unknown user", :handle => "notfound" do
        response_body.should == "Owner could not be found."
        status.should == 404
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }

      example_request "Getting a user's gems - XML" do
        response_body.should == user.rubygems.with_versions.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }

      example_request "Getting a user's gems - YAML" do
        response_body.should == user.rubygems.with_versions.to_yaml
        status.should == 200
      end
    end
  end
end
