require 'rails_helper'

describe ApplicationHelper, :type => :helper do
  it 'formats the flash messages' do
    expect(helper.notice_message).to eq('')
    expect(helper.notice_message.html_safe?).to eq(true)

    controller.flash[:notice] = 'hello'
    expect(helper.notice_message).to eq('<div class="alert alert-success"><a class="close" data-dismiss="alert" href="#">x</a>hello</div>')
    controller.flash[:notice] = nil

    controller.flash[:warning] = 'hello'
    expect(helper.notice_message).to eq('<div class="alert alert-warning"><a class="close" data-dismiss="alert" href="#">x</a>hello</div>')
    controller.flash[:warning] = nil

    controller.flash[:alert] = 'hello'
    expect(helper.notice_message).to eq('<div class="alert alert-alert"><a class="close" data-dismiss="alert" href="#">x</a>hello</div>')
    controller.flash[:alert] = nil

    controller.flash[:error] = 'hello'
    expect(helper.notice_message).to eq('<div class="alert alert-error"><a class="close" data-dismiss="alert" href="#">x</a>hello</div>')
    controller.flash[:error] = nil
    
    expect(helper.insert_code_menu_items_tag).to include('class="insert_code"')
  end

  describe "admin?" do
    let(:user) { Factory :user }
    let(:admin) { Factory :admin }

    it "knows you are not an admin" do
      expect(helper.admin?(user)).to be_falsey
    end

    it "knows who is the boss" do
      expect(helper.admin?(admin)).to be_truthy
    end

    it "use current_user if user not given" do
      allow(helper).to receive(:current_user).and_return(admin)
      expect(helper.admin?(nil)).to be_truthy
    end

    it "use current_user if user not given a user" do
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.admin?(nil)).to be_falsey
    end

    it "know you are not an admin if current_user not present and user param is not given" do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.admin?(nil)).to be_falsey
    end
  end

  describe "wiki_editor?" do
    let(:non_editor) { Factory :non_wiki_editor }
    let(:editor) { Factory :wiki_editor }

    it "knows non editor is not wiki editor" do
      expect(helper.wiki_editor?(non_editor)).to be_falsey
    end

    it "knows wiki editor is wiki editor" do
      expect(helper.wiki_editor?(editor)).to be_truthy
    end

    it "use current_user if user not given" do
      allow(helper).to receive(:current_user).and_return(editor)
      expect(helper.wiki_editor?(nil)).to be_truthy
    end

    it "know you are not an wiki editor if current_user not present and user param is not given" do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.wiki_editor?(nil)).to be_falsey
    end
  end

  describe "owner?" do
    require "ostruct"
    let(:user) { Factory :user }
    let(:user2) { Factory :user }
    let(:item) { OpenStruct.new :user_id => user.id }

    it "knows who is owner" do
      expect(helper.owner?(nil)).to be_falsey

      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.owner?(item)).to be_falsey

      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.owner?(item)).to be_truthy

      allow(helper).to receive(:current_user).and_return(user2)
      expect(helper.owner?(item)).to be_falsey
    end
  end
end
