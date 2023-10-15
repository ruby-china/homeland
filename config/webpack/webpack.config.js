const { generateWebpackConfig } = require('shakapacker');
const { merge } = require('webpack-merge');
const webpack = require("webpack");
const webpackConfig = generateWebpackConfig();

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const customConfig = {
  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
    }),
  ],
  resolve: {
    extensions: [".js", ".ts", ".tsx", ".js.erb", ".css", ".scss"],
  },
}

module.exports = merge(webpackConfig, customConfig)
