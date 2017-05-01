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

def compile(source)
  stack = []
  l = source.length
  i = 0
  while i < l do
    c = source[i,2]
    case c
    when '\\*'
      e = stack.pop
      s = State.new(:split, nil, nil, nil)
      s.out2 = e.start
      e.patch(s)
      stack.push(Frag.new(s, StateList.new(s)))
      i+=2
    when '\\.'
      e2 = stack.pop
      e1 = stack.pop
      e1.patch(e2.start)
      stack.push(Frag.new(e1.start, e2.out))
      i+=2
    when '\\|'
      e2 = stack.pop
      e1 = stack.pop
      s = State.new(:split, nil, nil, nil)
      s.out2 = e1.start
      s.out1 = e2.start
      stack.push(Frag.new(s, e1.out.append(e2.out)))
      i+=2
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
def dotfile(s)
     dict = {}
     buf = ["digraph {"]
     buf_relation = []
     buf_var = []
     buf_var << var(s)
     buf_relation << relation(s)
    dict[s.id] = s
    ss = next_states(dict, s)
    while !ss.empty? do
      nss = []
      ss.each do|s|
        buf_var << var(s)
        buf_relation << relation(s) 
        nss << next_states(dict, s)
      end
      ss = nss.flatten 
    end
    buf = buf + buf_var + buf_relation
    buf << "}"
    buf.join("\n")
end
def next_states(dict, s)
  case s.type
  when :value
    [s.out1].map{|v| 
        v2 = (v && dict[v.id])? nil : v
        dict[v.id] = v
        v2
    }.compact
  when :split
    [s.out1, s.out2].map{|v|
      v2 = (v && dict[v.id])? nil : v
      dict[v.id] = v
      v2
    }.compact
  when :end
    []
  end
end
def var(s)
  "s#{s.id} [label = \"#{s.to_s}\"]" 
end
def relation(s)
  buf = []
  buf << "s#{s.id} -> s#{s.out1.id};" if s.out1
  buf << "s#{s.id} -> s#{s.out2.id};" if s.out2
  buf.join("\n")
end 
