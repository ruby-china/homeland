require "spec_helper"

describe SitesController do
  describe "routing" do

    it "routes to #index" do
      get("/sites").should route_to("sites#index")
    end

    it "routes to #new" do
      get("/sites/new").should route_to("sites#new")
    end
    
    it "routes to #edit" do
      get("/sites/1/edit").should route_to("sites#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sites").should route_to("sites#create")
    end

  end
end
