#!/usr/bin/env ruby
require './parser.rb'
require 'minitest/autorun'

class ParserTest < MiniTest::Test
  def test_arrow
    p = Parser.new
    assert_equal("<-->", p.parse("1,<-->,2").regex)
    assert_equal("->->", p.parse("1,->->,2").regex)
    assert_equal("<-<-", p.parse("1,<-<-,2").regex)
    assert_equal("-><-", p.parse("1,-><-,2").regex)
  end
  def test_comma
 p = Parser.new
 src = <<-SRC
1,,,->,1
1.11->.1
1,33->,1
1,01<-,2
SRC
  p.parse(src)
  assert_equal("\\(,,->\\|11->\\|33->\\)\\*\\(01<-\\)", p.regex)
  end
  def test_normal
 p = Parser.new
 src = <<-SRC
1,00->,1
1,11->,1
1,33->,1
1,01<-,2
SRC
  p.parse(src)
  assert_equal("\\(00->\\|11->\\|33->\\)\\*\\(01<-\\)", p.regex)
  end
end
