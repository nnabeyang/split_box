class Machine
  def initialize(state)
    @init  = state
  end
  def step
    state_lists = []
    is = []
    strs = []
    @state_lists.each.with_index do|states, j|
      pos = @is[j]
      str = @strs[j]
      states.each do|s|
        if s.b == str[pos]
          new_str = str.dup
          s.exec(pos, new_str)
          strs << new_str
          is << pos + s.steps
          state_lists << next_states(s.out1)
        end
      end
    end
    @is = is
    @strs = strs
    state_lists
  end
  def isMatch
    v = nil
    i = 0
    @state_lists.each do |states|
      if (states.find{|s| s.type == :end})
         v = i
         break
      end
      i += 1
    end
    v
  end
  def exec(str, pos=0)
    @state_lists = [next_states(@init)]
    @strs = [str]
    @is = [pos]
    while !isMatch && @state_lists.size > 0 do
      @state_lists = step
    end
    (i = isMatch) ? @strs[i] : nil
  end
  def next_states(state)
    nstates = []
    return [] if !state
    case state.type
    when :split
       nstates << next_states(state.out1)
       nstates << next_states(state.out2)
    else
       nstates << state
    end
    nstates.flatten.compact
  end
end

class Frag
  attr_accessor :start, :out
  def initialize(start, out)
    @start = start
    @out = out
  end
  def patch(other)
    @out.each do |state|
      state.out1 = other
    end
  end
end

class StateList
   include Enumerable
   attr_accessor :head, :next
   def initialize(head)
     @head = head
   end
   def append(l)
    e = self
    while e.next do
      e = e.next
    end
    e.next = l
    self
   end
   def each
     e = self
     while e && e.head do
       yield e.head
       e = e.next
     end
   end
end

class State
  attr_reader :b, :steps, :type, :a
  attr_accessor :out1, :out2
  def initialize(type, b, a, steps)
    @type = type
    @b = b
    @a = a
    @steps = steps
  end
  def inspect
    "S(#{@type}, #{@b.inspect}, #{@a.inspect}, #{@steps})"
  end
  def to_s
    "S(#{@type},#{@b},#{@a}, #{@steps})"
  end
  def exec(i, str)
    str[i] = @a
  end
end

def compile(source)
  stack = []
  l = source.length
  i = 0
  while i < l do
    c = source[i]
    case c
    when '*'
      e = stack.pop
      s = State.new(:split, nil, nil, nil)
      s.out2 = e.start
      e.patch(s)
      stack.push(Frag.new(s, StateList.new(s)))
      i+=1
    when '.'
      e2 = stack.pop
      e1 = stack.pop
      e1.patch(e2.start)
      stack.push(Frag.new(e1.start, e2.out))
      i+=1
    when '|'
      e2 = stack.pop
      e1 = stack.pop
      s = State.new(:split, nil, nil, nil)
      s.out2 = e1.start
      s.out1 = e2.start
      stack.push(Frag.new(s, e1.out.append(e2.out)))
      i+=1
    else
      s = State.new(:value, source[i, 1], source[i + 1, 1], ('->' == source[i + 2, 2])? 1 : -1)
      i+= 4
      stack.push(Frag.new(s, StateList.new(s)))
    end
  end
  e = stack.pop
  e.patch(State.new(:end, nil, nil, nil))
  e.start
end
