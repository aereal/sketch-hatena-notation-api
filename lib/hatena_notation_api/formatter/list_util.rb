module HatenaNotationApi
  module Formatter
  end
end

module HatenaNotationApi::Formatter::ListUtil
  def self.grouping(list)
    results = []
    accum = []
    initial = [ { level: 0 } ] + list.reverse
    initial.each_cons(2) do |prev, current|
      if current[:level] == 1
        results.unshift({ text: current[:text], children: accum })
        accum = []
      elsif current[:level] > prev[:level]
        accum.unshift({ text: current[:text], children: [] })
      else # parent
        current = { text: current[:text], children: accum.clone }
        accum = [current]
      end
    end
    results
  end
end
