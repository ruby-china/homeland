require 'rails_helper'

describe RubyChina::APIHelpers, :type => :request do
  before { extend RubyChina::APIHelpers }

  it "should use size that is valid" do
    stub_params(:size => 10)
    expect(page_size).to eq(10)
  end

  it "should use max size if page size provided greater than that" do
    stub_params(:size => max_page_size + 1)
    expect(page_size).to eq(max_page_size)
  end

  it "should use default size if page size provided is not valid" do
    stub_params(:size => 'a')
    expect(page_size).to eq(default_page_size)
  end

  private
  def stub_params(p = {})
    allow(self).to receive(:params).and_return(p)
  end
end
