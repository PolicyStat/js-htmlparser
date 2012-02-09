desc 'Build JavaScript'
task :default do
    `coffee -c src/lib/HTMLParser.coffee src/test/test_htmlparser.coffee`
end

desc 'Run webserver for testing'
task :serve do
    puts 'Python SimpleHTTPServer listening on port 9000'
    puts 'Run tests: http://localhost:9000/src/test/test.html'
    `python -m SimpleHTTPServer 9000`
end
