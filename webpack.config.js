const path = require('path');
// const HtmlWebpackPlugin = require('html-webpack-plugin');
const HandlebarsPlugin = require("handlebars-webpack-plugin");

module.exports = {
  mode: 'development',
  entry: {
    index: './src/js/index.js'
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    publicPath: '/dist',
    filename: 'js/[name].bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: { presets: ['@babel/env'] }
      },
      {
        test: /\.(css|s[ac]ss)$/i,
        use: ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader']
      }
    ]
  },
  plugins: [
    // new HtmlWebpackPlugin({
    //   template: 'src/templates/index.html'
    // })
    new HandlebarsPlugin({
      entry: path.join(process.cwd(), "src", "templates", "*.hbs"),
      output: path.join(process.cwd(), "dist", "[name].html"),
      partials: [
        path.join(process.cwd(), "src", "templates", "layouts", "*.hbs"),
        path.join(process.cwd(), "src", "templates", "components", "*.hbs"),
      ],
    })
  ]
}
