desc 'Build JavaScript'
task :default do
    message = "// This file was AUTOMATICALLY generated
    var VERSION = '$(git describe --dirty)', BUILDDATE = '$(date)';"
    `echo "#{message}" > src/lib/HTMLParser.js`
    `echo "#{message}" > src/test/test_htmlparser.js`
    `coffee -p src/lib/HTMLParser.coffee >> src/lib/HTMLParser.js`
    `coffee -p src/test/test_htmlparser.coffee >> src/test/test_htmlparser.js`
end

desc 'Run tests'
task :test do
    sh 'coffee src/test/test_htmlparser.coffee'
end

desc 'Run webserver for testing'
task :serve do
    puts 'Run tests: http://localhost:9000/src/test/test.html'
    sh 'python -m SimpleHTTPServer 9000'
end
