require "rails_helper"

describe PagesController, :type => :controller do
  let(:page) { Factory :page }
  let(:user) { Factory :wiki_editor }

  describe ":index" do
    it "should have an index action" do
      get :index
      expect(response).to be_success
    end
  end

  describe ":show" do
    it "should respond with 404 to invalid request made by unauthenticated user" do
      get :show, :id => "non_existent"
      expect(response).not_to be_success
      expect(response.status).to eq(404)
    end

    it "should prompt user to create new page if page not found but user is logged in" do
      sign_in user
      get :show, :id => "non_existent_yet"
      expect(response).not_to be_success
      expect(response.status).to eq(302)
      expect(response).to redirect_to(new_page_path(:title => "non_existent_yet"))
    end

    it "should respond to valid show action" do
      get :show, :id => page.slug
      expect(response).to be_success
    end
  end

  describe ":new" do
    it "should not allow anonymous access" do
      get :new
      expect(response).not_to be_success
    end

    it "should allowed access from authenticated user" do
      sign_in user
      get :new
      expect(response).to be_success
    end
  end

  describe ":edit" do
    it "should not allow anonymous access" do
      get :edit, :id => page.id
      expect(response).not_to be_success
    end

    it "should allowed access from authenticated user" do
      sign_in user
      get :edit, :id => page.id
      expect(response).to be_success
    end
  end

  describe ":create" do
    it "should not allow anonymous access" do
      post :create
      expect(response).not_to be_success
    end

    it "should create new page if all is well" do
      sign_in user
      params = Factory.attributes_for(:page)
      post :create, :page => params
      expect(response).to redirect_to page_path(params[:slug])
    end

    it "should not create new page if title is not present" do
      sign_in user
      params = Factory.attributes_for(:page)
      params[:title] = ""
      post :create, :page => params
      expect(response).to render_template(:new)
    end
  end

  describe ":update" do
    it "should not allow anonymous access" do
      put :update, :id => 1
      expect(response).not_to be_success
    end

    it "should update page if all is well" do
      sign_in user
      params = Factory.attributes_for(:page)
      page = Page.create!(params)
      params[:title] = "shiney new title"
      params[:change_desc] = "updated title"
      put :update, :page => params, :id => page.id
      expect(response).to redirect_to(page_path(page.slug))
    end

    it "should not update page if change_desc is not present" do
      sign_in user
      params = Factory.attributes_for(:page)
      page = Page.create!(params)
      params[:title] = "shiney new title"
      params[:change_desc] = nil
      put :update, :page => params, :id => page.id
      expect(response).to render_template(:edit)
    end
  end

  describe ":recent" do
    it "should have a recent action" do
      get :recent
      expect(response).to be_success
    end
  end

  describe ":preview" do
    it "should give a text from markdown" do
        sign_in user
        post :preview, {body: '123'}
        expect(response.body).to eq("<p>123</p>\n")
    end
  end
end
