module HatenaNotationApi
  module Formatter
  end
end

module HatenaNotationApi::Formatter::ListUtil
  def self.grouping(list)
    root_level = 1
    prev_level = root_level - 1
    results = []
    accum = []
    list.reverse.each do |e|
      if e[:level] == root_level
        results.unshift({ text: e[:text], children: accum })
        accum = []
      elsif e[:level] > prev_level
        accum.unshift({ text: e[:text], children: [] })
      else # parent
        current = { text: e[:text], children: accum.clone }
        accum = [current]
      end
      prev_level = e[:level]
    end
    results
  end
end
