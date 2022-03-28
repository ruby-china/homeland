module.exports = {
  content: [
      "./app/views/**/*.html.erb",
      "./app/components/**/*.html.erb",
      "./app/helpers/**/*.rb",
      "./app/javascript/**/*.js"
    ],
  theme: {
    extend: {},
  },
  prefix: 'tw-',
  plugins: [],
  corePlugins: {
    preflight: false,
  }
}