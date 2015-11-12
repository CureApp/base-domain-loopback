
module.exports = (grunt) ->

    grunt.config.init

        mochaTest:
            options:
                reporter: 'spec'
                require: [
                    'espower-coffee/guess'
                    'coffee-script/register'
                    'spec/export-globals.js'
                ]

            spec:
                src: [
                    'spec/*.coffee'
                    'spec/lib/*.coffee'
                ]

            single:
                src: [
                    grunt.option('file') ? 'spec/lib/loopback-domain-facade.coffee'
                ]

        coffee:
            dist:
                expand: true
                cwd: 'src'
                src: ['**/*.coffee']
                dest: 'dist/'
                ext: '.js'
                extDot: 'first'
                options:
                    bare: true


        yuidoc:
            options:
                paths: ['src', 'node_modules/base-domain/src/lib']
                syntaxtype: 'coffee'
                extension: '.coffee'
            master:
                options:
                    outdir: 'doc'



    grunt.loadNpmTasks 'grunt-mocha-test'
    grunt.loadNpmTasks 'grunt-contrib-yuidoc'
    grunt.loadNpmTasks 'grunt-contrib-coffee'

    grunt.registerTask 'default', 'mochaTest:spec'
    grunt.registerTask 'single', 'mochaTest:single'
    grunt.registerTask 'build', ['coffee:dist']
