var gulp = require('gulp')
var watch = require('gulp-watch')

var less = require('gulp-less')
var concat = require('gulp-concat')
var uglify = require('gulp-uglify')
var spritesmith = require('gulp.spritesmith')
var gm= require('gulp-gm')

gulp.task('compile-less', ['build-images'], function() {
    var src = [
        'src/base/base.less',
        , 'src_generated/style.less'
    ]
    gulp.src(src)
        .pipe(less({ plugins: [require('less-plugin-glob')] }))
        .pipe(concat('style.css'))
        .pipe(gulp.dest('build'))
})

gulp.task('compile-coffee', function() {
  var src = [
    'src/base/script.coffee',
    'src/actions/*.coffee',
    'src/store/*.coffee',
    'src/atomic/**/*/components/*.coffee',
    'src/atomic/**/script.coffee',
    'src/base/end.coffee',
    'src/base/exports.coffee'
    ]
  gulp.src(src)
    .pipe(concat('script.coffee'))
    .pipe(gulp.dest('build'))
    .pipe(gulp.dest('../components'))
})

gulp.task('compile-fonts', function() {
  gulp.src([])
  .pipe(gulp.dest('build/public/fonts'))
})

gulp.task('start', ['build'], function() {
  var src = [
    'src/atomic/**/*',
    'src/base/*',
    'src/actions/*',
    'src/store/*'
  ]
  watch(src, {verbose:true})
    .on('data', function () {
        gulp.start('build');
    });
})

gulp.task('copy-assets', function() {
  gulp.src('asset/*')
    .pipe(gulp.dest('build/asset'))
});

gulp.task('build', ['compile-fonts', 'compile-less', 'compile-coffee','build-images', 'copy-assets'], function() {
})

gulp.task('build-images', function() {
  var spriteData = gulp.src('asset/retina/*.png')
    .pipe(spritesmith({
      imgName: 'sprite@2x.png'
      , cssName: 'style.less'
      , algorithm: 'binary-tree'
      , enging: 'gm'
      , cssFormat: 'less'
      , cssTemplate:'.spriterc'
      , cssOpts: {
        functions: true
        , cssClass: function(item) {
          return '.sprite-' + item.name
        }
        , random: function() {
          return Math.random().toString().substr(2)
        }
      }
    }))

  spriteData.img
    .pipe(gulp.dest('build/asset'))
  spriteData.css
    .pipe(gulp.dest('src_generated'))

  var spriteData = gulp.src('asset/retina/*.png')
    .pipe(gm(function (gmfile, done) {
      gmfile.size(function (err, size) {
        done(null, gmfile.resize(
          size.width * 0.5,
          size.height * 0.5
      ));
      });
    }))
    .pipe(spritesmith({
      imgName: 'sprite.png'
      , cssName: 'style.less'
      , algorithm: 'binary-tree'
      , enging: 'gm'
      , cssFormat: 'less'
      , cssTemplate:'.spriterc'
      , cssOpts: {
        functions: true
        , cssClass: function(item) {
          return '.sprite-' + item.name
        }
        , random: function() {
          return Math.random().toString().substr(2)
        }
      }
    }))
  spriteData.img
    .pipe(gulp.dest('build/asset'))
})
