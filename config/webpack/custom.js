const webpack = require("webpack");

module.exports = {
  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
    }),
  ],
  resolve: {
    extensions: [".js", ".ts", ".tsx", ".js.erb", ".css", ".scss"],
  },
};
