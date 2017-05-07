#!/usr/bin/env ruby
require 'split_box/reg2post'
module SplitBox
  class Parser
    attr_reader :dict
    def initialize
      @dict = {}
      @n = 1
      @s = 2
    end

    def key_name(from, to)
        "#{from}->#{to}"
    end
    
    def parse(src)
      @dict = {}
      @n = 1
      src.each_line do |line|
        next unless is_comment line
        a = parse_instruction(line)
        @dict[key_name(a[0], a[2])] = [@dict[key_name(a[0], a[2])], a[1]].compact.join('\\|')
        @n = [@n, a[2].to_i].max
      end
      self
    end

    def parse_instruction(line)
      line.strip!
      idx = [line.rindex('->'), line.rindex('<-')].compact.max
      [line[0...(idx - 3)], line[idx - 2, 4], line[(idx + 3)..-1]]
    end

    def is_comment(line)
      !!line.match(/\A\d+/)
    end

    def regex
      dict = @dict
      @s = 2
      dict = step(dict) while @s <= @n
      dict[key_name(1, @n)]
    end

    def postfix
      SplitBox.reg2post(regex)
    end

    def dotfile
      buf = ['digraph {']
      (1..@n).each do |i|
        buf << var(i)
      end
      @dict.each do |k, v|
        buf << relation(k, v)
      end
      buf << '}'
      buf.join("\n")
    end

    def var(i)
      "s#{i} [label = \"#{i}\"]"
    end

    def relation(k, v)
      a = k.split('-')
      "s#{a[0]} -> s#{a[1]} [label =\"#{v.tr(' ', '␣').gsub('->', '→').gsub('<-', '←')}\"];"
    end

    def d(prev, i, j, k)
      a = [prev[key_name(i, j)], prev[key_name(j, j)], prev[key_name(j, k)]]
      if !prev[key_name(j, k)] || !prev[key_name(i, j)]
        prev[key_name(i, k)]
      else
        a = [paren("#{a[0]}#{star(paren(a[1]))}#{paren(a[2])}"), paren(prev[key_name(i, k)])].compact
        if a.empty?
          nil
        elsif a.size == 2
          paren(a.join('\\|'))
        elsif a.size == 1
          a[0]
        end
      end
    end

    def paren(v)
      !v || v == '' ? nil : "\\(#{v}\\)"
    end

    def star(v)
      v ? "#{v}\\*" : nil
    end

    def step(prev)
      dict = {}
      if @s == @n
        dict[key_name(1, @n)] = prev[key_name(1, 1)] ? "#{star(paren(prev[key_name(1, 1)]))}#{paren(prev[key_name(1, @n)])}"
                                                     : prev[key_name(1, @n)]
        @s += 1
      else
        dict[key_name(1, 1)] = d(prev, 1, @s, 1)
        ((@s + 1)..@n).each do |k|
          if v = d(prev, 1, @s, k)
            dict[key_name(1, k)] = v
          end
          if k < @n && (v = d(prev, k, @s, 1))
            dict[key_name(k, 1)] = v
          end
        end
        ((@s + 1)...@n).each do |i|
          ((@s + 1)..@n).each do |k|
            if v = d(prev, i, @s, k)
              dict[key_name(i, k)] = v
            end
          end
        end
        if v = d(prev, @n, @s, @n)
          dict[key_name(@n, @n)] = v
        end
        @s += 1
      end
      dict
    end
  end
end
