#!/usr/bin/env ruby

def reg2post(reg)
  buf = [] 
  parens = []
  i = 0 # 結合待ちのオペレータの数 
  j = 0 # number of "|"
  l = reg.length
  k = 0
  while k < l do
    c = reg[k]
    case c
    when '|'
      i-=1
      if i == 1
        buf << "."
        i-=1
      end
      j+=1
      k+=1
    when '('
      if i > 1
        buf << "."
        i-=1
      end
      parens << {i: i, j: j}
      i = 0
      j = 0
      k+=1
    when ')'
      buf << "." if i > 1
      buf << ("|" * j)
      paren = parens.pop
      i = paren[:i]
      j = paren[:j]
      i+=1 
      k+=1
    when '*'
      buf << '*'
      k+=1
    else
      if i > 1
        buf << '.'
        i-=1 
      end
      buf << reg[k, 4]
      k+=4  
      i+=1
    end
  end
  buf << '.' if i > 1
  buf << ('|' * j)
  buf.join 
end


