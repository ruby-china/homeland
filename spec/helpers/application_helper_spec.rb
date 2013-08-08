require 'spec_helper'

describe ApplicationHelper do
  it 'formats the flash messages' do
    helper.notice_message.should == ''
    helper.notice_message.html_safe?.should == true

    controller.flash[:notice] = 'hello'
    helper.notice_message.should == '<div class="alert alert-success"><a class="close" data-dismiss="alert" href="#">x</a>hello</div>'
    controller.flash[:notice] = nil

    controller.flash[:warning] = 'hello'
    helper.notice_message.should == '<div class="alert alert-warning"><a class="close" data-dismiss="alert" href="#">x</a>hello</div>'
    controller.flash[:warning] = nil

    controller.flash[:alert] = 'hello'
    helper.notice_message.should == '<div class="alert alert-alert"><a class="close" data-dismiss="alert" href="#">x</a>hello</div>'
    controller.flash[:alert] = nil

    controller.flash[:error] = 'hello'
    helper.notice_message.should == '<div class="alert alert-error"><a class="close" data-dismiss="alert" href="#">x</a>hello</div>'
    controller.flash[:error] = nil
    
    helper.insert_code_menu_items_tag.should include('class="insert_code"')
  end

  describe "admin?" do
    let(:user) { Factory :user }
    let(:admin) { Factory :admin }

    it "knows you are not an admin" do
      helper.admin?(user).should be_false
    end

    it "knows who is the boss" do
      helper.admin?(admin).should be_true
    end

    it "use current_user if user not given" do
      helper.stub(:current_user).and_return(admin)
      helper.admin?(nil).should be_true
    end

    it "use current_user if user not given a user" do
      helper.stub(:current_user).and_return(user)
      helper.admin?(nil).should be_false
    end

    it "know you are not an admin if current_user not present and user param is not given" do
      helper.stub(:current_user).and_return(nil)
      helper.admin?(nil).should be_false
    end
  end

  describe "wiki_editor?" do
    let(:non_editor) { Factory :non_wiki_editor }
    let(:editor) { Factory :wiki_editor }

    it "knows non editor is not wiki editor" do
      helper.wiki_editor?(non_editor).should be_false
    end

    it "knows wiki editor is wiki editor" do
      helper.wiki_editor?(editor).should be_true
    end

    it "use current_user if user not given" do
      helper.stub(:current_user).and_return(editor)
      helper.wiki_editor?(nil).should be_true
    end

    it "know you are not an wiki editor if current_user not present and user param is not given" do
      helper.stub(:current_user).and_return(nil)
      helper.wiki_editor?(nil).should be_false
    end
  end

  describe "owner?" do
    require "ostruct"
    let(:user) { Factory :user }
    let(:user2) { Factory :user }
    let(:item) { OpenStruct.new :user_id => user.id }

    it "knows who is owner" do
      helper.owner?(nil).should be_false

      helper.stub(:current_user).and_return(nil)
      helper.owner?(item).should be_false

      helper.stub(:current_user).and_return(user)
      helper.owner?(item).should be_true

      helper.stub(:current_user).and_return(user2)
      helper.owner?(item).should be_false
    end
  end
end
