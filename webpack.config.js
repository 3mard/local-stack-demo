const ZipPlugin = require('zip-webpack-plugin');
const path = require('path');

module.exports = {
  target: 'node',
  entry: `${process.cwd()}/code/index.js`,
  mode: 'production',
  devtool: 'source-map',
  module: {
    rules: [
      {
        test: /\.ts?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      }
    ]
  },
  externals: {
    'aws-sdk': 'aws-sdk',
    child_process: 'child_process',
    dns: 'dns',
    net: 'net',
    fs: 'fs',
    tls: 'tls',
    crypto: 'crypto',
    util: 'util',
    module: 'module'
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js', '.json']
  },
  output: {
    filename: 'index.js',
    path: path.resolve(process.cwd(), 'dist'),
    libraryTarget: 'commonjs2'
  },
  performance: {
    hints: false
  },
  optimization: {
    minimize: false
  },
  plugins: [
    new ZipPlugin({
      filename: `${path.basename(process.cwd())}.zip`,
      fileOptions: {
        mtime: new Date(0),
        mode: 0o100664,
        compress: true,
        forceZip64Format: false
      }
    })
  ]
};
