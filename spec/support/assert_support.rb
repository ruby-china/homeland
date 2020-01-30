module AssertSupport
  def assert_html_equal(excepted, html)
    assert_equal excepted.strip.gsub(/>[\s]+</, "><"), html.strip.gsub(/>[\s]+</, "><")
  end
end