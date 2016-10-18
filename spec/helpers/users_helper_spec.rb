require 'rails_helper'

describe UsersHelper, type: :helper do
  describe 'user_avatar_width_for_size' do
    it 'should calculate avatar width correctly' do
      expect(helper.user_avatar_width_for_size(:xs)).to eq(16)
      expect(helper.user_avatar_width_for_size(:sm)).to eq(32)
      expect(helper.user_avatar_width_for_size(:md)).to eq(48)
      expect(helper.user_avatar_width_for_size(:lg)).to eq(96)
      expect(helper.user_avatar_width_for_size(233)).to eq(233)
    end
  end

  describe 'user_name_tag' do
    it 'should result right html in normal' do
      user = build(:user)
      expect(helper.user_name_tag(user)).to eq(link_to(user.login, user_path(user.login), class: 'user-name', 'data-name' => user.name))
    end

    it 'should result right html with string param and downcase url' do
      login = 'Monster'
      expect(helper.user_name_tag(login)).to eq(link_to(login, user_path(login), class: 'user-name', 'data-name' => login))
    end

    it 'should out name with Team' do
      user = build(:team)
      expect(helper.user_name_tag(user)).to eq(link_to(user.name, user_path(user.login), class: 'team-name', 'data-name' => user.name))
    end

    it 'should result empty with nil param' do
      expect(helper.user_name_tag(nil)).to eq('匿名')
    end
  end

  describe 'user_avatar_tag' do
    it 'should work if user not exist' do
      expect(user_avatar_tag(nil)).to eq image_tag('avatar/md.png', class: 'media-object avatar-48')
    end

    it 'should work if user exists' do
      user = create(:user)
      img = image_tag(user.letter_avatar_url(96), class: 'media-object avatar-48')
      expect(user_avatar_tag(user)).to eq link_to(raw(img), user_path(user))
    end

    it 'should work if avatar exist' do
      user = create(:avatar_user)
      image_url = user.avatar.url(:md)
      img = image_tag(image_url, class: 'media-object avatar-48')
      expect(user_avatar_tag(user)).to eq link_to(raw(img), user_path(user))
    end

    it 'should work with different size' do
      expect(user_avatar_tag(nil, :lg)).to eq image_tag('avatar/lg.png', class: 'media-object avatar-96')
    end

    it 'should work with timestamp param' do
      user = create(:avatar_user)
      image_url = user.avatar.url(:md) + "?t=#{user.updated_at.to_i}"
      img = image_tag(image_url, class: 'media-object avatar-48')
      expect(user_avatar_tag(user, :md, timestamp: true)).to eq link_to(raw(img), user_path(user))
    end

    it 'should work if link is false' do
      user = create(:avatar_user)
      image_url = user.avatar.url(:md) + "?t=#{user.updated_at.to_i}"
      img = image_tag(image_url, class: 'media-object avatar-48')
      expect(user_avatar_tag(user, :md, timestamp: true, link: false)).to eq img
    end

    it 'should alias to team_avatar_tag' do
      expect(team_avatar_tag(nil)).to eq image_tag('avatar/md.png', class: 'media-object avatar-48')
    end
  end

  describe 'render_user_level_tag' do
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

  describe 'block_node_tag' do
    let(:user) { create(:user) }
    let(:node) { create(:node) }
    before { allow(helper).to receive(:current_user).and_return(user) }

    it 'should work if current_user is nil' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.block_node_tag(node)).to eq ''
    end

    it 'should work if node is nil' do
      expect(helper.block_node_tag(nil)).to eq ''
    end

    it 'should work if not blocked' do
      expect(helper.block_node_tag(node)).to eq %(<a data-id="#{node.id}" class="btn btn-default btn-sm button-block-node" href="#"><i class="fa fa-eye-slash"></i><span>忽略节点</span></a>)
    end

    it 'should work if blocked' do
      user.blocked_node_ids << node.id
      expect(helper.block_node_tag(node)).to eq %(<a title="忽略后，社区首页列表将不会显示这里的内容。" data-id="#{node.id}" class="btn btn-default btn-sm button-block-node active" href="#"><i class="fa fa-eye-slash"></i><span>取消屏蔽</span></a>)
    end
  end

  describe 'block_user_tag' do
    let(:user) { create(:user) }
    let(:block_user) { create(:user) }
    before { allow(helper).to receive(:current_user).and_return(user) }

    it 'should work' do
      expect(helper.block_user_tag(block_user)).to eq %(<a data-id="#{block_user.login}" class="button-block-user btn btn-default btn-block" href="#"><i class="fa fa-eye-slash"></i><span>屏蔽</span></a>)
    end

    it 'should work if blocked' do
      user.blocked_user_ids << block_user.id
      expect(helper.block_user_tag(block_user)).to eq %(<a title="忽略后，社区首页列表将不会显示此用户发布的内容。" data-id="#{block_user.login}" class="button-block-user btn btn-default btn-block active" href="#"><i class="fa fa-eye-slash"></i><span>取消屏蔽</span></a>)
    end

    it 'should work if disable to block' do
      expect(helper.block_user_tag(nil)).to eq ''
      expect(helper.block_user_tag(user)).to eq ''
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.block_user_tag(nil)).to eq ''
    end
  end

  describe 'follow_user_tag' do
    let(:user) { create(:user) }
    let(:follow_user) { create(:user) }
    before { allow(helper).to receive(:current_user).and_return(user) }

    it 'should work' do
      expect(helper.follow_user_tag(follow_user)).to eq %(<a data-id="#{follow_user.login}" class="button-follow-user btn btn-primary btn-block" href="#"><i class="fa fa-user"></i><span>关注</span></a>)
    end

    it 'should work if followed' do
      allow(user).to receive(:followed?).and_return(true)
      expect(helper.follow_user_tag(follow_user)).to eq %(<a data-id="#{follow_user.login}" class="button-follow-user btn btn-primary btn-block active" href="#"><i class="fa fa-user"></i><span>取消关注</span></a>)
    end

    it 'should work if disable to follow' do
      expect(helper.follow_user_tag(nil)).to eq ''
      expect(helper.follow_user_tag(user)).to eq ''
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.follow_user_tag(nil)).to eq ''
    end
  end
end
