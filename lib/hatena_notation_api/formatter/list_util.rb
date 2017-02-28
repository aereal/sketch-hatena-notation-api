module HatenaNotationApi
  module Formatter
  end
end

module HatenaNotationApi::Formatter::ListUtil
  def self.grouping(list)
    accum = []
    initial = [ { level: 0 } ] + list.reverse
    initial.each_cons(2).reduce([]) do |results, (prev, current)|
      if current[:level] == 1
        n = { text: current[:text], children: accum.clone }
        accum = []
        [n] + results
      elsif current[:level] > prev[:level]
        accum.unshift({ text: current[:text], children: [] })
        results
      else # parent
        current = { text: current[:text], children: accum.clone }
        accum = [current]
        results
      end
    end
  end
end
