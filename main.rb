#!/usr/bin/env ruby
require './parser.rb'
require './reg2post.rb'
require './nfa.rb'

def main
 p = Parser.new
  if ARGV[0] == "-v"
    ARGV.shift
    write_graphs
  else
    src = open(ARGV[0]).read
    p.parse(src)
    post = reg2post(p.regex)
    s = compile(post)
    m = Machine.new(s)
    puts m.exec(ARGV[1]).inspect
  end
end
def write_graphs 
  Dir.mkdir('./images') unless Dir.exist?("./images")
  p = Parser.new
  ARGV.each do|path|
    p.parse(IO.read(path))
    fn = File.basename(path, '.sb')
    IO.popen("dot -Tpng -o ./images/#{fn}.png", "r+") do|io|
    io.puts p.dotfile
    io.close_write
    end 
  end
end

main
