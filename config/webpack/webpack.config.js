const { webpackConfig, merge } = require("shakapacker")
const customConfig = require("./custom")

module.exports = merge(webpackConfig, customConfig);
