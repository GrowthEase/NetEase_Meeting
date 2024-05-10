import { terser } from 'rollup-plugin-terser'
import json from '@rollup/plugin-json'
import babel from '@rollup/plugin-babel'
import commonjs from '@rollup/plugin-commonjs'
import resolve from '@rollup/plugin-node-resolve'
import alias from 'rollup-plugin-alias'
import typescript from 'rollup-plugin-typescript2'
import postcss from 'rollup-plugin-postcss'
import replace from 'rollup-plugin-replace'
import image from '@rollup/plugin-image'
import pkg from './package.json'
import url from 'postcss-url'
const path = require('path')

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
      include: ['*.ts+(|x)', '**/*.ts+(|x)'],
      tsconfig: './tsconfig.json',
      useTsconfigDeclarationDir: true,
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
      input: path.resolve(__dirname, 'src/index.tsx'),
      output: [
        {
          file: `${outputPath}/index.umd.js`,
          name: 'NEMeetingKit',
          format: 'umd',
          exports: 'default',
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
      treeshake: {
        moduleSideEffects: false,
      },
    },
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
      treeshake: {
        moduleSideEffects: false,
      },
    },
  ]
}

export default [...buildConfig('web')]
