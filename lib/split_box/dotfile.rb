module SplitBox
  class << self
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
end 
end
