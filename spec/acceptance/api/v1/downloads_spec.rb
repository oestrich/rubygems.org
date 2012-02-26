require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Downloads" do
  let(:user) { Factory(:user) }

  let(:headers) { { "HTTP_ACCEPT" => accept } }
  let(:client) { RspecApiDocumentation::TestClient.new(self, :headers => headers) }

  let(:rubygem) { Factory(:rubygem_with_downloads) }
  let(:version) { Factory(:version, :rubygem => rubygem, :number => '1.0.0') }
  let(:version2) { Factory(:version, :rubygem => rubygem, :number => '1.0.1') }

  before do
    Download.stub!(:count => 50)
    Download.stub!(:for_rubygem).with(rubygem.name).and_return(36)
    Download.stub!(:for_version).with(version.full_name).and_return(14)
  end

  get "/api/v1/downloads" do
    context "json" do
      let(:accept) { "application/json" }

      example "Getting download count - JSON" do
        do_request

        response_body.should == "{\"total\":50}"
        status.should == 200
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }

      example "Getting download count - XML" do
        do_request

        response_body.should == {:total => 50}.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }

      example "Getting download count - YAML" do
        do_request

        response_body.should == {:total => 50}.to_yaml
        status.should == 200
      end
    end

    context "any" do
      let(:accept) { "text/text" }

      example "Getting download count - Any" do
        do_request

        response_body.should == "50"
        status.should == 200
      end
    end
  end

  get "/api/v1/downloads/:id.:format" do
    context "json" do
      let(:accept) { "application/json" }
      let(:format) { "json" }

      example "Viewing download stats for a single gem - Missing gem" do
        do_request(:id => "notfound-0.0.1")

        response_body.should == "This rubygem could not be found."
        status.should == 404
      end

      example "Viewing download stats for a single gem - JSON" do
        do_request(:id => version.full_name)

        response_body.should == { :total_downloads => 36, :version_downloads => 14 }.to_json
        status.should == 200
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }
      let(:format) { "xml" }

      example "Viewing download stats for a single gem - XML" do
        do_request(:id => version.full_name)

        response_body.should == { :total_downloads => 36, :version_downloads => 14 }.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }
      let(:format) { "yaml" }

      example "Viewing download stats for a single gem - YAML" do
        do_request(:id => version.full_name)

        response_body.should == { :total_downloads => 36, :version_downloads => 14 }.to_yaml
        status.should == 200
      end
    end
  end

  get "/api/v1/downloads/top.:format" do
    before do
      Download.stub!(:most_downloaded_today => [[version, 20], [version2, 15]])
    end

    let(:hash) { {:gems => [[version.attributes, 20], [version2.attributes, 15]] } }

    context "json" do
      let(:accept) { "application/json" }
      let(:format) { "json" }

      example "Viewing top download stats - JSON" do
        do_request

        response_body.should == hash.to_json
        status.should == 200
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }
      let(:format) { "xml" }

      example "Viewing top download stats - XML" do
        do_request

        response_body.should == hash.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }
      let(:format) { "yaml" }

      example "Viewing top download stats - XML" do
        do_request

        response_body.should == hash.to_yaml
        status.should == 200
      end
    end
  end

  get "/api/v1/downloads/all.:format" do
    before do
      Download.stub!(:most_downloaded_all_time => [[version, 20], [version2, 15]])
    end

    let(:hash) { {:gems => [[version.attributes, 20], [version2.attributes, 15]] } }

    context "json" do
      let(:accept) { "application/json" }
      let(:format) { "json" }

      example "Viewing top download stats - JSON" do
        do_request

        response_body.should == hash.to_json
        status.should == 200
      end
    end

    context "xml" do
      let(:accept) { "application/xml" }
      let(:format) { "xml" }

      example "Viewing top download stats - XML" do
        do_request

        response_body.should == hash.to_xml
        status.should == 200
      end
    end

    context "yaml" do
      let(:accept) { "text/yaml" }
      let(:format) { "yaml" }

      example "Viewing top download stats - XML" do
        do_request

        response_body.should == hash.to_yaml
        status.should == 200
      end
    end
  end
end
