const { environment } = require('@rails/webpacker')

const extendConfig = {
  devtool: false,
  optimization: {
    splitChunks: {
      cacheGroups: {
        vendors: {
          test: /node_modules|lib\/assets|vendor/,
          name: 'vendors',
          enforce: true,
          chunks: 'all',
        },
      },
    },
  },
};

environment.config.merge(extendConfig);

module.exports = environment
