#!/usr/bin/env ruby
#require 'rubygems'
#require 'ruby_debug'
require 'test/unit'
require 'yaxml'
require 'load_files'

class TestSimpleParser < Test::Unit::TestCase

  def test_parser_from_yaml_to_yaxml_simple_case
    yaxml = YAXML::Yaxml.new( TestFiles::FILES['files/simple_test.yml'], {:root_name => "root"} )

    assert_equal TestFiles::FILES['files/simple_test.xml'], yaxml.to_s
  end

  def test_parser_from_yaxml_to_yaml_simple_case
    yaxml = YAXML::Yaxml.new( TestFiles::FILES['files/simple_test.xml'], {:from_yaxml => true} )
    json_to_compare = yaxml.to_json
    
    correct_json = YAML::load(TestFiles::FILES['files/simple_test.yml'])
    correct_json = stringing_values( correct_json )
    
    assert_block "Error parsing from YAXML" do
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

end
