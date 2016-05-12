require 'rails_helper'

describe UsersHelper, type: :helper do
  describe 'user_avatar_width_for_size' do
    it 'should calculate avatar width correctly' do
      expect(helper.user_avatar_width_for_size(:normal)).to eq(48)
      expect(helper.user_avatar_width_for_size(:small)).to eq(16)
      expect(helper.user_avatar_width_for_size(:large)).to eq(96)
      expect(helper.user_avatar_width_for_size(:big)).to eq(120)
      expect(helper.user_avatar_width_for_size(233)).to eq(233)
    end
  end

  describe 'user_name_tag' do
    it 'should result right html in normal' do
      user = create(:user)
      expect(helper.user_name_tag(user)).to eq(link_to(user.login, user_path(user.login), 'data-name' => user.name))
    end

    it 'should result right html with string param and downcase url' do
      login = 'Monster'
      expect(helper.user_name_tag(login)).to eq(link_to(login, user_path(login), 'data-name' => login))
    end

    it 'should result empty with nil param' do
      expect(helper.user_name_tag(nil)).to eq('匿名')
    end
  end

  describe 'user_avatar_tag' do 
    it "should work if user not exist" do 
      user_avatar_tag(nil).should eq image_tag("avatar/normal.png", class: "media-object avatar-48")
    end

    it "should work if user exists" do 
      user = create(:user)
      img = image_tag(user.letter_avatar_url(96), class: "media-object avatar-48")
      user_avatar_tag(user).should eq link_to(raw(img), user_path(user))
    end

    it "should work if avatar exist" do 
      user = create(:avatar_user)
      image_url = user.avatar.url(user_avatar_size_name_for_2x(:normal))
      img = image_tag(image_url, class: "media-object avatar-48")
      user_avatar_tag(user).should eq link_to(raw(img), user_path(user)) 
    end

    it "should work with different size" do 
      user_avatar_tag(nil, :large).should eq image_tag("avatar/large.png", class: "media-object avatar-96")
    end

    it "should work with timestamp param" do 
      user = create(:avatar_user)
      image_url = user.avatar.url(user_avatar_size_name_for_2x(:normal)) + "?t=#{user.updated_at.to_i}"
      img = image_tag(image_url, class: "media-object avatar-48")
      user_avatar_tag(user, :normal, timestamp: true).should eq link_to(raw(img), user_path(user)) 
    end

    it "should work if link is false" do 
      user = create(:avatar_user)
      image_url = user.avatar.url(user_avatar_size_name_for_2x(:normal)) + "?t=#{user.updated_at.to_i}"
      img = image_tag(image_url, class: "media-object avatar-48")
      user_avatar_tag(user, :normal, timestamp: true, link: false).should eq img 
    end
  end

  describe '.render_user_level_tag' do
    let(:user) { create(:user) }
    subject { helper.render_user_level_tag(user) }

    it 'admin should work' do
      allow(user).to receive(:admin?).and_return(true)
      is_expected.to eq '<span class="label label-danger role">管理员</span>'
    end

    it 'vip should work' do
      allow(user).to receive(:verified?).and_return(true)
      is_expected.to eq '<span class="label label-success role">高级会员</span>'
    end

    it 'hr should work' do
      allow(user).to receive(:hr?).and_return(true)
      is_expected.to eq '<span class="label label-success role">企业 HR</span>'
    end

    it 'blocked should work' do
      allow(user).to receive(:blocked?).and_return(true)
      is_expected.to eq '<span class="label label-warning role">禁言用户</span>'
    end

    it 'newbie should work' do
      allow(user).to receive(:newbie?).and_return(true)
      is_expected.to eq '<span class="label label-default role">新手</span>'
    end

    it 'normal should work' do
      is_expected.to eq '<span class="label label-info role">会员</span>'
    end
  end
end
