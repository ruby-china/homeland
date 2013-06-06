require "spec_helper"

describe SitesController do
  let(:user) { Factory :user, :replies_count => 100 }
  let(:user1) { Factory :user }
  describe ":index" do
    it "should have an index action" do
      get :index
      response.should be_success
    end
  end

  describe ":new" do
    it "should not allow anonymous access" do
      get :new
      response.should_not be_success
    end

    it "should allow access from authenticated user" do
      sign_in user
      get :new
      response.should be_success
    end
    
    it "should not allow access without use has replies_count less than 100" do
      sign_in user1
      get :new
      response.should_not be_success
    end
  end

  describe ":create" do
    let(:site_node) { Factory :site_node }
    it "should not allow anonymous access" do
      post :create
      response.should_not be_success
    end

    describe "authenticated" do
      before(:each) do
        sign_in user
      end

      it "should create new site if all is well" do
        params = Factory.attributes_for(:site, :site_node_id => site_node.id)
        post :create, :site => params
        response.should redirect_to(sites_path)
      end

      it "should not create new site if url is blank" do
        params = Factory.attributes_for(:site)
        params[:url] = ""
        post :create, :site => params
        response.should render_template(:new)
      end
    end
  end
end