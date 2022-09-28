const fs = require('fs')
const Koa = require('koa')
const route = require('koa-route')
const path = require('path')
const statics = require('koa-static')
const https = require('https')
const app = new Koa()

let str
// fs.readFile(path.resolve(__dirname, './dist/index.html'), "utf-8", (err, data) => {
//   if (err) {
//     ctx.body = "error found"
//   }
//   str = data.toString();
// })

const main = (ctx) => {
  // ctx.response.type = 'html'
  // ctx.response.body = fs.createReadStream(path.join(__dirname,  '/index.html'))
  if (ctx.url !== '/index.html') {
    // 重定向回到自身
    ctx.body = str
  }
}
// const toMain = ctx => {
//   ctx.response.redirect('/')
// }

const staticFile = statics(path.join(__dirname, '/lib'))

app.use(staticFile)
// app.use(route.get('/', toMain))
app.use(route.get('/*', main))

app.listen(3001)

const options = {
  //key: fs.readFileSync("./ssh/key.pem", "utf8"),
  //cert: fs.readFileSync("./ssh/cert.pem", "utf8")
  key: fs.readFileSync('./cert/key.pem', 'utf8'),
  cert: fs.readFileSync('./cert/cert.pem', 'utf8'),
}
https.createServer(options, app.callback()).listen(3002)
