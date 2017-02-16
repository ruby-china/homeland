require 'rails_helper'
require 'fileutils'

describe 'image_thumb' do
  describe Homeland::ImageThumb do
    context 'pragma: false' do
      it '#exists?' do
        image_thumb = Homeland::ImageThumb.new('test', 'xs')
        expect(image_thumb.exists?).to be_falsey
      end
    end

    context 'pragma: true' do
      it '#exists?' do
        FileUtils.mkdir_p(Rails.root.join('public', 'uploads'))
        FileUtils.cp Rails.root.join('app', 'assets', 'images', 'favicon.png'), Rails.root.join('public', 'uploads', 'favicon.png')

        image_thumb = Homeland::ImageThumb.new('favicon.png', 'large', pragma: true)
        expect(image_thumb.exists?).to be_truthy

        image_thumb = Homeland::ImageThumb.new('favicon.png', 'lg', pragma: true)
        expect(image_thumb.exists?).to be_truthy

        image_thumb = Homeland::ImageThumb.new('favicon.png', 'md', pragma: true)
        expect(image_thumb.exists?).to be_truthy

        image_thumb = Homeland::ImageThumb.new('favicon.png', 'sm', pragma: true)
        expect(image_thumb.exists?).to be_truthy

        image_thumb = Homeland::ImageThumb.new('favicon.png', 'xs', pragma: true)
        expect(image_thumb.exists?).to be_truthy

        image_thumb = Homeland::ImageThumb.new('favicon.png', 'other', pragma: true)
        expect(image_thumb.exists?).to be_truthy
      end

    end
  end
end
