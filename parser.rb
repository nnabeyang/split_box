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
      line.chomp!
      a = line.split(',')
      @dict["#{a[0]}-#{a[2]}"] = [@dict["#{a[0]}-#{a[2]}"], a[1] ].compact.join("|")
      @n = [@n, a[2].to_i].max
    end
    while @s <= @n
      step
    end
    @dict["1-#{@n}"]
  end
  def d(i, j, k)
    a = [@dict["#{i}-#{j}"], @dict["#{j}-#{j}"], @dict["#{j}-#{k}"]]
    if a.index(nil)
      @dict["#{i}-#{k}"]
    else
     a = [paren("#{a[0]}#{star(paren(a[1]))}#{paren(a[2])}"), paren(@dict["#{i}-#{k}"])].compact
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
  def step
    if @s  == @n
      dict = {}
      dict["1-#{@n}"] = (@dict["1-1"]) ? "#{star(paren(@dict["1-1"]))}#{paren(@dict["1-#{@n}"])}" :  @dict["1-#{@n}"]
      @dict = dict
      @s += 1
    else
      dict = {}
      dict["1-1"] = d(1, @s, 1)
      ((@s+1)..@n).each do|k|
        if v = d(1, @s, k)
          dict["1-#{k}"] = v 
        end
        if k < @n && (v = d(k, @s, 1))
          dict["#{k}-1"] = v
        end 
      end
      ((@s+1)...@n).each do|i|
        ((@s+1)..@n).each do|k|
          if v = d(i, @s, k)
            dict["#{i}-#{k}"] = v
          end 
        end
      end
      if v = d(@n, @s, @n)
        dict["#{@n}-#{@n}"] = v
      end 
      @s += 1
      @dict = dict
    end
  end
end

