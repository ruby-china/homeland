const { environment } = require("@rails/webpacker");
const erb = require("./loaders/erb");

const extendConfig = {
  devtool: false,
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
