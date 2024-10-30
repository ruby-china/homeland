const colors = require("tailwindcss/colors");

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class", '[data-theme="dark"]'],
  content: [
    "./app/views/**/*.html.erb",
    "./app/components/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./plugins/**/*.erb",
  ],
  theme: {
    colors: {
      ...colors,
      gray: colors.neutral,
      red: colors.rose,
    },
    extend: {},
  },
  plugins: [],
  corePlugins: {
    preflight: false,
  },
};
