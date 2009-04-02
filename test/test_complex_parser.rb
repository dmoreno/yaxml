#!/usr/bin/env ruby
#require 'rubygems'
#require 'ruby_debug'
require 'test/unit'
require 'yaxml'
require 'load_files'

class TestParser < Test::Unit::TestCase

  def test_parser_from_yaml_to_yaxml_complex_case
    yaxml = YAXML::Yaxml.new( TestFiles::FILES['files/test.yml'], {:root_name => "invoice"} )

    assert_equal TestFiles::FILES['files/test.xml'], yaxml.to_s
  end
  
  def test_parser_from_yaxml_to_yaml_complex_case
    yaxml = YAXML::Yaxml.new( TestFiles::FILES['files/test.xml'], {:from_yaxml => true} )
    json_to_compare = yaxml.to_json
    
    correct_json = YAML::load TestFiles::FILES['files/test.yml']
    correct_json = stringing_values correct_json
    correct_json = delete_last_eol correct_json
    
    assert_block "#{json_to_compare.inspect} expected but was #{correct_json.inspect}" do
      json_to_compare == correct_json
    end
  end
  
  private
  # Convert a JSON as:
  # { "one" => 1, "two" => 2 }
  # to:
  # { "one" => "1", "two" => "2" }
  # This make the json easier to compare
  def stringing_values( hash )
    if hash.is_a?Hash
      hash.each_pair do | k, v |
        hash[k] = stringing_values v
      end
    elsif hash.is_a?Array
      hash.map do | v |
        stringing_values v
      end
    else # case of String, Float, Date...
      hash = hash.to_s
    end
    hash
  end

  # Find all string in a JSON to convert them from:
  # "458 Walkman Dr.\nSuite #292\n"
  # to:
  # "458 Walkman Dr.\nSuite #292"
  def delete_last_eol( hash )
    if hash.is_a?Hash
      hash.each_pair do | k, v |
        hash[k] = delete_last_eol v
      end
    elsif hash.is_a?Array
      hash.map do | v |
        delete_last_eol v
      end
    elsif String
      # If last character is \n, get out that character.
      hash.sub!(/\n$/, '')
    end
    hash
  end

end
