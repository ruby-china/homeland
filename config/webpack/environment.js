const { environment } = require("@rails/webpacker");
const erb = require("./loaders/erb");
const webpack = require("webpack");

const extendConfig = {
  devtool: false,
  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
    }),
  ],
  optimization: {
    splitChunks: {
      cacheGroups: {
        vendors: {
          test: /node_modules|lib\/assets|vendor/,
          name: "vendors",
          enforce: true,
          chunks: "all",
        },
      },
    },
  },
};

environment.config.merge(extendConfig);
environment.loaders.prepend("erb", erb);
module.exports = environment;
