gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
yuidoc     = require 'gulp-yuidoc'


gulp.task 'coffee', ->

    gulp.src 'src/**/*.coffee'
        .pipe(coffee bare: true)
        .pipe(gulp.dest 'dist')


gulp.task 'yuidoc', ->

    gulp.src ['src/**/*.coffee', 'node_modules/base-domain/src/lib/**/*.coffee']
        .pipe(yuidoc({
            syntaxtype: 'coffee'
            project:
                name: 'base-domain-loopback'
        }))
        .pipe(gulp.dest('doc'))
        .on('error', console.log)

module.exports = gulp
