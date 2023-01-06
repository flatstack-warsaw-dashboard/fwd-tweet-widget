import { URL } from 'node:url';
import webpack from 'webpack';

export default {
  context: new URL('./src', import.meta.url).pathname,
  mode: 'development',
  entry: {},
  output: {
    filename: '[name].js',
    chunkFilename: '[id].js',
    path: new URL('./dist', import.meta.url).pathname,
    clean: true,
    publicPath: 'auto',
  },
  resolve: {
    extensions: ['.js'],
  },
  plugins: [
    new webpack.container.ModuleFederationPlugin({
      name: 'FwdTweetWidget',
      filename: 'remote.js',
      exposes: { '.': './index.js' },
      shared: {},
    }),
    new webpack.DefinePlugin({
      __API_URL__: `'${process.env.LAMBDA_API_URL}'`,
    }),
  ],
  devServer: {
    allowedHosts: 'all',
    webSocketServer: 'ws',
    client: {
      webSocketTransport: 'ws',
      webSocketURL: 'ws://10.14.95.51:8080/ws'
    },
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
};
