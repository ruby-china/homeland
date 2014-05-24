ignore([%r{^bin/*}, %r{^config/*}, %r{^db/*}, %r{^lib/*}, %r{^log/*}, %r{^public/*}, %r{^tmp/*}])

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(scss|css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
end
