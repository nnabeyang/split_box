require 'split_box/version'
require 'split_box/parser'
require 'split_box/nfa'
module SplitBox
  class << self
  def build_machine(source)
    p = SplitBox::Parser.new
    p.parse(source)
    SplitBox::Machine.new(SplitBox.compile(p.postfix))
  end

  def compile(source)
    stack = []
    l = source.length
    i = 0
    while i < l
      c = source[i, 2]
      case c
      when '\\*'
        e = stack.pop
        s = SplitBox::State.new(:split, nil, nil, nil)
        s.out2 = e.start
        e.patch(s)
        stack.push(SplitBox::Frag.new(s, SplitBox::StateList.new(s)))
        i += 2
      when '\\.'
        e2 = stack.pop
        e1 = stack.pop
        e1.patch(e2.start)
        stack.push(SplitBox::Frag.new(e1.start, e2.out))
        i += 2
      when '\\|'
        e2 = stack.pop
        e1 = stack.pop
        s = SplitBox::State.new(:split, nil, nil, nil)
        s.out2 = e1.start
        s.out1 = e2.start
        stack.push(SplitBox::Frag.new(s, e1.out.append(e2.out)))
        i += 2
      else
        s = SplitBox::State.new(:value, source[i, 1], source[i + 1, 1], '->' == source[i + 2, 2] ? 1 : -1)
        i += 4
        stack.push(SplitBox::Frag.new(s, SplitBox::StateList.new(s)))
      end
    end
    e = stack.pop
    e.patch(SplitBox::State.new(:end, nil, nil, nil))
    e.start
  end
end
end
