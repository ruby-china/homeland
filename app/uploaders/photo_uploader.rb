# coding: utf-8
class PhotoUploader < BaseUploader
  process :resize_to_limit => [680, nil]
end
