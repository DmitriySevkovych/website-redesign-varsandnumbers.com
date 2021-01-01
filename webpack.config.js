const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

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
            // Handlebars
            {
                test: /\.hbs$/,
                use: [
                    {
                        loader: 'handlebars-loader',
                        options: {
                            // Path to your custom js file, which has Handlebars with custom helpers registered
                            runtime: path.join(__dirname, 'handlebars.config.js'),
                            precompileOptions: {
                                knownHelpersOnly: false,
                            }
                        },
                    }
                ]
            },
            // JS
            {
                test: /\.(js|jsx)$/,
                exclude: [/node_modules/, /extlib/],
                use: ['babel-loader', 'eslint-loader'],
                // options: { presets: ['@babel/env'] }
            },
            // SASS, CSS
            {
                test: /\.(css|s[ac]ss)$/i,
                use: ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader']
            }
            // Images
            // Fonts
            // Files
        ]
    },
    plugins: [
        new HtmlWebpackPlugin({
            template: 'src/templates/index.hbs'
        })
    ]
}
