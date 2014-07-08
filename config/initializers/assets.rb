# Be sure to restart your server when you modify this file.
# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(application.css app.js topics.css topics.js
  window.css front.css cpanel.css
  users.css pages.css pages.js notes.css notes.js
  mobile.css home.css)
