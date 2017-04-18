#!/usr/bin/env ruby
require './parser.rb'
require './reg2post.rb'
require './nfa.rb'

def main
 p = Parser.new
  if ARGV[0] == "-v"
    ARGV.shift
    white_graphs
  else
    src = open(ARGV[0]).read
    p.parse(src)
    post = reg2post(p.regex)
    s = compile(post)
    m = Machine.new(s)
    puts m.exec(ARGV[1]).inspect
  end
end
def white_graphs 
  Dir.mkdir('./images') unless Dir.exist?("./images")
  ARGV.each do|path|
    p = Parser.new
    p.parse(open(path).read)
    fn = File.basename(path, '.sb')
    IO.popen("dot -Tpng -o ./images/#{fn}.png", "r+") do|io|
    io.puts p.dotfile
    io.close_write
    end 
  end
end

main
