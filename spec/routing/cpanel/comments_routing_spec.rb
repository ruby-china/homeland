require "spec_helper"

describe Cpanel::CommentsController do
  describe "routing" do

    it "routes to #index" do
      get("/cpanel/comments").should route_to("cpanel/comments#index")
    end

    it "routes to #new" do
      get("/cpanel/comments/new").should route_to("cpanel/comments#new")
    end

    it "routes to #show" do
      get("/cpanel/comments/1").should route_to("cpanel/comments#show", :id => "1")
    end

    it "routes to #edit" do
      get("/cpanel/comments/1/edit").should route_to("cpanel/comments#edit", :id => "1")
    end

    it "routes to #create" do
      post("/cpanel/comments").should route_to("cpanel/comments#create")
    end

    it "routes to #update" do
      put("/cpanel/comments/1").should route_to("cpanel/comments#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/cpanel/comments/1").should route_to("cpanel/comments#destroy", :id => "1")
    end

  end
end
