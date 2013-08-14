module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      main:
        expand: true
        cwd: 'src'
        src: ['whitespace.coffee']
        dest: 'bin'
        ext: '.js'
      node:
        expand: true
        cwd: 'node'
        src: 'ws.coffee'
        dest: 'bin'
        ext: '.js'
    watch:
      app:
        files: ['src/*.coffee', '!src/whitespace.coffee', 'node/*.coffee']
        tasks: ['concat', 'coffee', 'clean']
    concat: 
      dist:
        src: ['src/global_variables.coffee', 'src/util.coffee', 'src/commands.coffee', 'src/objects.coffee', 'src/exports.coffee']
        dest: 'src/whitespace.coffee'
    clean: [
      'src/whitespace.coffee'
    ]

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  # Default task.
  grunt.registerTask 'default', ['concat', 'coffee', 'clean']