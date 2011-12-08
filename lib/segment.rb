# coding: utf-8
require 'rmmseg'

RMMSeg::Dictionary.load_dictionaries

class Segment
  def self.split(text)
    result = []
    algor = RMMSeg::Algorithm.new(text)
    loop do
      tok = algor.next_token
      break if tok.nil?
      result << tok.text.force_encoding("utf-8")
    end
    result
  end
end