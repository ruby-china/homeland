const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/components/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./plugins/**/*.erb",
  ],
  theme: {
    screens: {
      'xs': '480px',
      ...defaultTheme.screens,
    },
    extend: {},
  },
  plugins: [],
  corePlugins: {
    preflight: false,
  },
};
