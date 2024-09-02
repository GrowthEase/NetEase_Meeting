import json from '@rollup/plugin-json'
import commonjs from '@rollup/plugin-commonjs'
import { nodeResolve } from '@rollup/plugin-node-resolve'
import typescript from '@rollup/plugin-typescript'
import { createRequire } from 'node:module'

const require = createRequire(import.meta.url)
const pkg = require('./package.json')

import { fileURLToPath } from 'node:url'

const outputPath = fileURLToPath(new URL('./dist', import.meta.url))

const output = [
  {
    file: `${outputPath}/index.cjs.js`,
    format: 'cjs',
    exports: 'named',
  },
  {
    file: `${outputPath}/index.esm.js`,
    format: 'esm',
    exports: 'named',
  },
  {
    file: `${outputPath}/index.umd.js`,
    name: 'NEMeetingKit',
    format: 'umd',
    exports: 'named',
  },
]

const treeShake = {
  moduleSideEffects: false,
}

export default {
  input: `./src/index.ts`,
  output,
  plugins: [
    nodeResolve({
      jsnext: true,
      preferBuiltins: true,
      browser: true,
    }),
    commonjs({
      browser: true,
    }),
    typescript({
      tsconfig: './tsconfig.json',
    }),
    json(),
  ],
  treeShake,
  external: Object.keys(pkg.dependencies || {}),
}
