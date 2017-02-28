require 'minitest/autorun'

require 'awesome_print'

require_relative '../lib/hatena_notation_api/formatter/list_util'

class ListTest < Minitest::Test
  def mu_pp(obj)
    obj.ai
  end

  def test_list_3
    input = [
      { level: 1, text: 'C' },
      { level: 1, text: 'perl' },
      { level: 2, text: 'perl 5' },
      { level: 3, text: 'perl 5.8.8' },
      { level: 1, text: 'ruby' },
      { level: 2, text: 'ruby 2.3' },
    ]
    expected = [
      {
        text: 'C',
        children: [],
      },
      {
        text: 'perl',
        children: [
          {
            text: 'perl 5',
            children: [
              { text: 'perl 5.8.8', children: [] },
            ],
          },
        ],
      },
      {
        text: 'ruby',
        children: [
          { text: 'ruby 2.3', children: [] },
        ],
      },
    ]
    assert_equal expected, HatenaNotationApi::Formatter::ListUtil.grouping(input)
  end

  def test_list_2
    input = [
      { level: 1, text: 'perl' },
      { level: 2, text: 'perl 5' },
    ]
    expected = [
      {
        text: 'perl',
        children: [
          { text: 'perl 5', children: [] },
        ],
      },
    ]
    assert_equal expected, HatenaNotationApi::Formatter::ListUtil.grouping(input)
  end
end
