module SplitBox
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
  attr_reader :b, :steps, :type, :a, :id
  attr_accessor :out1, :out2
  @@count = 0
  def initialize(type, b, a, steps)
    @type = type
    @b = b
    @a = a
    @steps = steps
    @id = @@count+=1 
  end
  def inspect
    "S(#{@id}, #{@type}, #{@b.inspect}, #{@a.inspect}, #{@steps})"
  end
  def to_s
    "S(#{@id}, #{@type},#{@b},#{@a}, #{@steps})"
  end
  def exec(i, str)
    str[i] = @a
  end
end
end
