require 'spec_helper'

describe "topics/show.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  let(:topic) { FactoryGirl.create(:topic) }
  before { controller.stub(:current_user => user) }

  it 'escapes title in social share button' do
    topic.title = 'f\'></div><button id="danger" onclick="javascript:alert(\'ooh\')">share</button><div style="display:none"'
    assign(:topic, topic)

    render

    doc = Nokogiri::HTML.fragment(rendered)
    expect(doc.at('button#danger')).to be_nil
  end
end
