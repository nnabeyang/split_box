#!/usr/bin/env ruby
require 'test_helper'

class MainTest < MiniTest::Test
  def test_default
    s = SplitBox.compile('10->')
    assert_equal('0', s.exec(0, '1'))
    m = SplitBox::Machine.new(s)
    assert_equal('0', m.exec('1'))
  end

  def test_dot
    s = SplitBox.compile('10->10->\\.')
    m = SplitBox::Machine.new(s)
    assert_equal('00', m.exec('11'))
  end

  def test_star
    s = SplitBox.compile('10->\\*  <-\\.')
    m = SplitBox::Machine.new(s)
    assert_equal('0000 ', m.exec('1111 '))
    s = SplitBox.compile('.|->\\*  <-\\.')
    m = SplitBox::Machine.new(s)
    assert_equal('|||| ', m.exec('.... '))
  end

  def test_alt
    s = SplitBox.compile('10->01->\\|')
    m = SplitBox::Machine.new(s)
    assert_equal('0', m.exec('1'))
    assert_equal('1', m.exec('0'))
  end
end
