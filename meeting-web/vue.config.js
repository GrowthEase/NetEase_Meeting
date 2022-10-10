/*
 * vue config
 * */
const fs = require('fs-extra')
const path = require('path')
const isWebsite = process.env.VUE_APP_VERSION === 'website'
const isNeedHash = process.env.NEED_HASH === 'true'

function resolve(dir) {
  return path.join(__dirname, dir)
}
module.exports = {
  devServer: {
    host: '0.0.0.0',
    port: 8020,
    overlay: {
      warnings: false,
      errors: true,
    }
  },
  outputDir: isWebsite ? 'dist' : 'lib',
  runtimeCompiler: isWebsite,
  filenameHashing: isWebsite,
  lintOnSave: false,
  configureWebpack: (config) => {
    if (process.env.NODE_ENV === 'development') {
      config.devtool = 'inline-source-map'
    }
  },
  chainWebpack: (config) => {
    config.resolve.alias
      .set('assets', resolve('src/assets'))
      .set('~', resolve('src/components'))
    config.module
      .rule('images')
      .use('url-loader')
      .loader('url-loader')
      .tap((options) => Object.assign(options, { limit: 30000 }))
    if (!isWebsite && process.env.NODE_ENV === 'production') {
      config.module.rule('ts').uses.delete('cache-loader')
      config.module
        .rule('ts')
        .use('ts-loader')
        .loader('ts-loader', {
          exclude: /node_modules/,
        })
        .tap((opts) => {
          opts.transpileOnly = false
          opts.happyPackMode = false
          return opts
        })
    }
    if (isWebsite && isNeedHash) {
      config.output.filename('[name]-[chunkhash].js').end()
    }
  },
  css: { extract: false },
  parallel: false,
  productionSourceMap: !isWebsite, // sourcemap
  publicPath: '/app/',
  /*,
    chainWebpack: config => {
      config.module
        .rule('js')
        .test(/\.jsx?$/)
        .exclude
          .clear()
          .add(/NIM_Web_*\.js/)
    }*/
}
