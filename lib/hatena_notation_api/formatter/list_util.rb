module HatenaNotationApi
  module Formatter
  end
end

module HatenaNotationApi::Formatter::ListUtil
  def self.grouping(list)
    initial = [ { level: 0 } ] + list.reverse
    reduced = initial.each_cons(2).reduce({ temp: [], results: [] }) {|accum, (prev, current)|
      if current[:level] == 1
        n = { text: current[:text], children: accum[:temp] }
        {
          temp: [],
          results: [n] + accum[:results],
        }
      elsif current[:level] > prev[:level]
        accum.merge(
          temp: [{ text: current[:text], children: [] }] + accum[:temp],
        )
      else # parent
        accum.merge(
          temp: [{ text: current[:text], children: accum[:temp] }],
        )
      end
    }
    reduced[:results]
  end
end
