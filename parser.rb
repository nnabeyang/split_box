#!/usr/bin/env ruby
class Parser
  attr_reader :dict
  def initialize
    @dict = {}
    @n = 1
    @s = 2 
  end
  def parse(src)
    src.each_line do|line|
      line.strip!
      a = line.split(',')
      @dict["#{a[0]}-#{a[2]}"] = [@dict["#{a[0]}-#{a[2]}"], a[1] ].compact.join("|")
      @n = [@n, a[2].to_i].max
    end
  end
  def regex
    dict = @dict
    while @s <= @n
      dict = step(dict)
    end
    dict["1-#{@n}"]
  end
  def d(prev, i, j, k)
    a = [prev["#{i}-#{j}"], prev["#{j}-#{j}"], prev["#{j}-#{k}"]]
    if a.index(nil)
      prev["#{i}-#{k}"]
    else
     a = [paren("#{a[0]}#{star(paren(a[1]))}#{paren(a[2])}"), paren(prev["#{i}-#{k}"])].compact
     if a.size == 0
       nil
     elsif a.size == 2 
      "(#{a.join('|')})"
     elsif a.size == 1
       a[0]
     end
    end
  end
  def paren(v)
    (!v || v == "")? nil : "(#{v})"
  end
  def star(v)
    (v)? "#{v}*" : nil
  end
  def step(prev)
    dict = {}
    if @s  == @n
      dict["1-#{@n}"] = (prev["1-1"]) ? "#{star(paren(prev["1-1"]))}#{paren(prev["1-#{@n}"])}" :  prev["1-#{@n}"]
      @s += 1
    else
      dict["1-1"] = d(prev, 1, @s, 1)
      ((@s+1)..@n).each do|k|
        if v = d(prev, 1, @s, k)
          dict["1-#{k}"] = v 
        end
        if k < @n && (v = d(prev, k, @s, 1))
          dict["#{k}-1"] = v
        end 
      end
      ((@s+1)...@n).each do|i|
        ((@s+1)..@n).each do|k|
          if v = d(prev, i, @s, k)
            dict["#{i}-#{k}"] = v
          end 
        end
      end
      if v = d(prev, @n, @s, @n)
        dict["#{@n}-#{@n}"] = v
      end 
      @s += 1
    end
    dict
  end
end

