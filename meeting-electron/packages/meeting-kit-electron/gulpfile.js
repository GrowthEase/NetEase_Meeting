const gulp = require('gulp')
const ts = require('gulp-typescript')
const del = require('del')

gulp.task('ts-js', async function () {
  const sourcePaths = ['src/**/*+(.ts|.js)']

  await gulp
    .src(sourcePaths)
    .pipe(ts.createProject('./tsconfig.json')())
    .pipe(gulp.dest('lib'))

  await gulp.src('src/**/*+(.jpg|.png)').pipe(gulp.dest('lib'))
})

gulp.task('clean', function () {
  return del(['lib'])
})

gulp.task('default', gulp.series('clean', gulp.parallel(['ts-js'])))
