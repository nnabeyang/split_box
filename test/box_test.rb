#!/usr/bin/env ruby
require 'test_helper'
class BoxTest < MiniTest::Test
  def create_machine(path)
    p = Parser.new
    p.parse(IO.read(path))
    s = SplitBox::compile(p.postfix)
    m = Machine.new(s)
  end
  def inp_str(i)
      (("0" * 6) + i.to_s(2) + " ")[-7..-1]
  end
  def test_broken_rich_and_poor
    m = create_machine('./box/broken_rich_and_poor.sb')
    (0...64).each do|i|
      str = inp_str(i)
      assert_equal(0, m.exec(str).count("1") % 2 )
    end
  end
  def test_rich_and_poor
    m = create_machine('./box/rich_and_poor.sb')
    (0...64).each do|i|
      str = inp_str(i)
      c = str[-2]
      assert_equal(c * 2, m.exec(str)[-2, 2])
    end
  end
  def test_str_cmp
    m = create_machine('./box/str_cmp.sb')
    (0..10).each do |i|
      (0..10).each do |j|
        str1 = i.to_s(2)
        str2 = j.to_s(2)
        xxxx = "X" * str1.size
        if i == j
          assert_equal(" #{xxxx}|#{xxxx} ", m.exec(" #{str1}|#{str2} "))
        else
          assert !m.exec(" #{str1}|#{str2} ")
        end
     end
    end
  end
  def test_copy
    m = create_machine("./box/copy.sb")
    (0..20).each do |i|
      str = i.to_s(2) 
      assert_equal(" #{str}|#{str} ", m.exec(" #{str}|#{' ' * str.size} "))
    end
  end
  def test_sum
  m = create_machine('./box/sum.sb')
  (0..10).each do|a|
    (0..10).each do|b|
      n = [a.to_s(2).length, b.to_s(2).length].max
      src = " #{("0" * n + a.to_s(2))[-n..-1]}+#{("0" * n + b.to_s(2))[-n..-1]} "
      assert_equal "#{(a+b).to_s(2)}", m.exec(src, 1).scan(/\w+/)[0]
    end
  end
  end
end
