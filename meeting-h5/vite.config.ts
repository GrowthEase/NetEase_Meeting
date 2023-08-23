import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import * as path from 'path'
import { terser } from 'rollup-plugin-terser'
import * as fs from 'fs'
const externals = ['react-dom', 'react']
// https://vitejs.dev/config/
const outputPath = path.resolve(__dirname, 'dist')
export default defineConfig({
  plugins: [react()],
  // server: {
  //   host: '0.0.0.0',
  //   https: {
  //     key: fs.readFileSync('./cert/key.pem'),
  //     cert: fs.readFileSync('./cert/cert.pem'),
  //   },
  // },
})
