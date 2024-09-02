import terser from '@rollup/plugin-terser'
import json from '@rollup/plugin-json'
import commonjs from '@rollup/plugin-commonjs'
import resolve from '@rollup/plugin-node-resolve'
import alias from 'rollup-plugin-alias'
import typescript from '@rollup/plugin-typescript'
import postcss from 'rollup-plugin-postcss'
import replace from '@rollup/plugin-replace'
import image from '@rollup/plugin-image'
import url from 'postcss-url'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url) // get the resolved path to the file
const __dirname = path.dirname(__filename) //
const platform = process.env.PLATFORM

function buildConfig(platform) {
  const outputPath = path.resolve(
    __dirname,
    'dist',
    platform === 'h5' ? '.' : platform
  )

  const plugins = [
    alias({
      entries: [{ find: '@', replacement: path.resolve(__dirname, 'src') }],
    }),
    resolve({
      jsnext: true,
      preferBuiltins: true,
      browser: true,
    }),
    commonjs({
      transformMixedEsModules: true,
    }),
    typescript({
      tsconfig: './tsconfig.json',
    }),
    replace({
      'process.env.NODE_ENV': JSON.stringify('production'),
      'process.env.PLATFORM': JSON.stringify(platform),
    }),
    image(),
    json(),
    postcss({
      extract: false,
      minimize: true,
      plugins: [
        url({
          url: 'inline',
        }),
      ],
      use: [
        [
          'less',
          {
            javascriptEnabled: true,
            modifyVars: { 'ant-prefix': 'nemeeting' },
          },
        ],
      ],
    }),
    terser({
      format: {
        comments: false,
      },
    }),
  ]

  return [
    {
      input: path.resolve(__dirname, 'src/kit/index.tsx'),
      output: [
        {
          file: `${outputPath}/index.umd.js`,
          name: 'NEMeetingKit',
          format: 'umd',
          exports: 'named',
        },
      ],
      plugins: [
        alias({
          entries: [
            {
              find: 'react',
              replacement: path.resolve(__dirname, '../../node_modules/react'),
            },
            {
              find: 'react-dom',
              replacement: path.resolve(
                __dirname,
                '../../node_modules/react-dom'
              ),
            },
          ],
        }),
        ...plugins,
      ],
      /*
      treeshake: {
        moduleSideEffects: false,
      },
      */
    },
    /*
    {
      input: path.resolve(__dirname, 'src/index.tsx'),
      output: [
        {
          file: `${outputPath}/index.cjs.js`,
          format: 'cjs',
          exports: 'default',
        },
        {
          file: `${outputPath}/index.esm.js`,
          format: 'esm',
          exports: 'default',
        },
      ],
      external: Object.keys(pkg.dependencies || {}),
      plugins,
    },
    */
  ]
}

export default [...buildConfig(platform === 'h5' ? 'h5' : 'web')]
