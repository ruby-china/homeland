#encoding: utf-8
require 'spec_helper'

describe "sign up and login" do

  it "let user sign up and login to the site" do
    visit '/'
    click_link '注册'
    fill_in '用户名', :with => 'ashchan'
    fill_in 'Email', :with => 'ashchan@gmail.com'
    fill_in '密码', :with => 'coolguy'
    fill_in '确认密码', :with => 'coolguy'
    click_button '提交注册信息'
    page.should have_content('活跃帖子')
    within("#userbar") do
      click_on 'ashchan'
    end

    click_link '退出'
    page.should have_content('退出成功.')

    click_link '登录'
    fill_in '用户名', :with => 'ashchan'
    fill_in '密码', :with => 'coolguy'
    click_button '登录'
    page.should have_content('活跃帖子')
  end
end
