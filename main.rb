#!/usr/bin/env ruby
require './parser.rb'
require './reg2post.rb'
require './nfa.rb'

def main
 p = Parser.new
 src = open(ARGV[0]).read
 p.parse(src)
 post = reg2post(p.regex)
 s = compile(post)
 m = Machine.new(s)
 puts m.exec(ARGV[1]).inspect
end

main
