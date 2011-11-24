require 'spec_helper'

describe ApplicationHelper do
  it 'formats the flash messages' do
    helper.notice_message.should == ''
    helper.notice_message.html_safe?.should == true

    controller.flash[:notice] = 'hello'
    helper.notice_message.should == '<div class="alert-message success"><a href="#" class="close">x</a>hello</div>'
    controller.flash[:notice] = nil

    controller.flash[:warning] = 'hello'
    helper.notice_message.should == '<div class="alert-message warning"><a href="#" class="close">x</a>hello</div>'
    controller.flash[:warning] = nil

    controller.flash[:alert] = 'hello'
    helper.notice_message.should == '<div class="alert-message alert"><a href="#" class="close">x</a>hello</div>'
    controller.flash[:alert] = nil

    controller.flash[:error] = 'hello'
    helper.notice_message.should == '<div class="alert-message error"><a href="#" class="close">x</a>hello</div>'
    controller.flash[:error] = nil
  end
end