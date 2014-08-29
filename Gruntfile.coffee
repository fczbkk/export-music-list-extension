module.exports = (grunt) ->

  require('load-grunt-tasks')(grunt)

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    coffeelint:
      src: 'src/coffee/*.coffee'

    coffee:
      options:
        join: true
      chrome:
        files:
          'extension/chrome/js/background.js': [
            'src/coffee/chrome/background.coffee'
          ]
          'extension/chrome/js/report.js': [
            'src/coffee/chrome/report.coffee'
          ]
          'extension/chrome/js/google-music/export.js': [
            'src/coffee/chrome/google-music/export.coffee'
          ]
          'extension/chrome/js/google-music/page_action.js': [
            'src/coffee/chrome/google-music/page_action.coffee'
          ]


    watch:
      options:
        atBegin: true
      coffee:
        files: ['src/coffee/**/*.coffee']
        tasks: ['coffeelint', 'coffee']
      images:
        files: ['src/images/**/*.*']
        tasks: ['responsive_images']

    bump:
      options:
        files: [
          'package.json'
          'extension/chrome/manifest.json'
        ]
        updateConfigs: ['pkg']
        commitFiles: ['-a']
        push: false

    compress:
      chrome:
        options:
          archive: 'build/<%= pkg.name %>-v<%= pkg.version %>.zip'
        expand: true
        cwd: 'extension/chrome/'
        src: ['**/*']

    responsive_images:
      icon_chrome:
        options:
          sizes: [
            {width: 128}
            {width: 48}
            {width: 38}
            {width: 19}
            {width: 16}
          ]
        files: [
          {
            expand: true
            src: ['icon.png']
            cwd: 'src/images/'
            dest: 'extension/chrome/images/'
          }
        ]

  grunt.registerTask 'build', [
    'coffeelint'
    'coffee'
    'bump'
    'compress'
  ]

  grunt.registerTask 'default', [
    'watch'
  ]
