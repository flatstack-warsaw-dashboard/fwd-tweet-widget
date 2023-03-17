import { URL } from 'node:url';
import webpack from 'webpack';

if (!process.env.LAMBDA_API_URL) {
  throw new Error("Provide LAMBDA_API_URL environment variable!");
}

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
      webSocketURL: 'ws://127.0.0.1:8080/ws'
    },
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
};
