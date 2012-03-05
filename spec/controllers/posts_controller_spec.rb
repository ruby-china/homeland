require "spec_helper"

describe PostsController do
  let(:blog_post) { Factory :post }
  let(:user) { Factory :user }
  describe ":index" do
    it "should have an index action" do
      get :index
      response.should be_success
    end
  end

  describe ":show" do
    it "should show a post" do
      get :show, :id => blog_post.id
      response.should be_success
    end
  end

  describe ":new" do
    it "should not allow anonymous access" do
      get :new
      response.should_not be_success
    end

    describe "authenticated" do
      it "should allow access from authenticated user" do
        sign_in user
        get :new
        response.should be_success
      end
    end
  end

  describe ":edit" do
    it "should not allow anonymous access" do
      get :edit, :id => blog_post.id
      response.should_not be_success
    end

    describe "authenticated" do
      it "should allow access from authenticated user" do
        sign_in user
        get :edit, :id => blog_post.id
        response.should be_success
      end
    end
  end

  describe ":create" do
    it "should not allow anonymous access" do
      post :create, :post => Factory.attributes_for(:post)
      response.should_not be_success
    end

    describe "authenticated" do
      before(:each) do
        sign_in user
      end
      it "should create new post if all is well" do
        params = Factory.attributes_for(:post)
        post :create, :post => params
        new_post = Post.where(:title => params[:title]).first
        new_post.user.should == user
        response.should redirect_to(post_path(new_post))
      end

      it "should not create new post if post params are invalid" do
        post :create, :post => {}
        response.should render_template(:new)
      end
    end
  end

  describe ":update" do
    it "should not allow anonymous access" do
      put :update, :post => Factory.attributes_for(:post)
      response.should_not be_success
    end
  end
end
