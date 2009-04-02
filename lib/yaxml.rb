####################################################
# 
# YAXML Module
# 
# This code is released under LGPL.
#
# This module make the next conversions:
#
# * YAML -> YAXML
# * JSON -> YAXML
# * YAXML -> YAML
# * YAXML -> JSON
#
# All conversions can use a file or a string as source.
#
# You can use this module in two ways:
#
# 1) Creating a Yaxml object
#    xml = Yaxml.new 'file.yml'
#    xml.write( $stdout, 2)
#    xml.to_json
#    xml.to_yaml
#
# 2) Using static methods of Yaxml module
#    xml = Yaxml::yaml2yaxml( 'file.yml' )
#    xml.write( $stdout, 2)
#
#    Also, you can use:
#    xml  = Yaxml::json2yaxml( { numbers: [ 1, 2, 3 ]} )
#    yaml = Yaxml::yaxml2yaml( 'file.yaxml' )
#    json = Yaxml::yaxml2json( 'file.yaxml' )
#
# Author:: Diego Moreno (dmoreno@dit.upm.es)
# License:: GNU Lesser General Public License (aka LGPL)
#

require "rexml/document"
require 'yaml'

module YAXML
  
  # Default root name
  DEFAULT_ROOT_NAME = "root"
  
  # Namespace for YAXML
  NAMESPACE = "http://yaml.org/xml"
  
  class Yaxml < REXML::Document
    
    # Constructor
    # source::
    #   It can be a String or a file name.
    # options::
    #   It is possible to pass the next options:
    # * <tt>:root_name</tt> It is the name of the root tag in the YAXML document. Defaults to +DEFAULT_ROOT_NAME+
    # * <tt>:from_yaxml</tt> If true, the source will be considered as YAXML input. If false, the source will be considered as YAML input. Defaults to :+false+
    #
    # Example of use:
    #   xml = Yaxml.new 'file.yml'
    #   xml.write( $stdout, 2)
    #   xml.to_json
    #   xml.to_yaml
    def initialize( source, options={} )
      super()
      
      if options[:from_yaxml]
        content = extract_content source
        doc = REXML::Document.new content
        self.add_element( doc.elements[1] ) if doc.elements[1]
        
      else #default is from_yaml
        options[:root_name] ||= DEFAULT_ROOT_NAME
        doc = YAXML::yaml2yaxml( source, options )
        
        self.add_element( doc.elements[1] ) if doc.elements[1]
      end
    
    end
	
    # The output is a YAML representation of YAXML object.
    def to_yaml
      YAXML::yaxml2yaml self
    end
	
    # The output is a JSON representation of YAXML object.
    def to_json
      YAXML::yaxml2json self
    end
    
    # The output is a YAXML representation of YAXML object.
    def to_yaxml
      self.to_s
    end
    
    private
    def extract_content source
      if File.exist?source
        File.open( source, "r" ).read # is a file
      else
        source # is a string
      end
    end
  
  end
  
  
  #################################################
  # From ANY To YAXML
  #################################################
  
  # Conversion YAML -> YAXML
  # 
  # source::
  #   It can be a YAML file in a String or a file name.
  # options::
  # * <tt>:root_name</tt> It is the name of the root tag in the YAXML document. Defaults to +DEFAULT_ROOT_NAME+
  #
  # Example of use:
  #   test.yml content
  #      one: 1
  #      two: 2.0 
  #      three:
  #        - apple
  #        - pear
  #      four: 
  #        aa: 11
  #        bb: 22
  #
  #   doc = YAXML.yaml2yaxml "test.yml"
  #   doc.write( $stdout, 2 )
  #   #-> <root xmlns:yaml='http://yaml.org/xml'>
  #         <three>
  #           <_>apple</_>
  #           <_>pear</_>
  #         </three>
  #         <two>2.0</two>
  #         <one>1</one>
  #         <four>
  #           <bb>22</bb>
  #           <aa>11</aa>
  #         </four>
  #       </root>
  def self.yaml2yaxml( source, options={} )

    options[:root_name] ||= DEFAULT_ROOT_NAME

    json = if source.is_a?String
             if File.exist?source
               YAML::load_file( source ) # is a file
             else
               YAML::load( source ) # is a string
             end
           elsif source.is_a?(Hash) || source.is_a?(Array)
             source
           end

    el = self.json2yaxml( json, options )
    doc = REXML::Document.new
    doc.add_element el
    doc

  end
  
  # Conversion JSON -> YAXML
  #
  # source::
  #   It can be a Array or Hash object or a file name.
  # options::
  # * <tt>:root_name</tt> It is the name of the root tag in the YAXML document. Defaults to +DEFAULT_ROOT_NAME+
  #
  # Example of use:
  #   
  #   json = {"one" => 1, "two" => 2.0, "three" => [ "apple", "pear"], "four" => {"aa" => 11, "bb" => 22}}
  #   doc = YAXML.json2yaxml json
  #   doc.write( $stdout, 2 )
  #   #-> <root xmlns:yaml='http://yaml.org/xml'>
  #         <three>
  #           <_>apple</_>
  #           <_>pear</_>
  #         </three>
  #         <two>2.0</two>
  #         <one>1</one>
  #         <four>
  #           <bb>22</bb>
  #           <aa>11</aa>
  #         </four>
  #       </root>
  def self.json2yaxml( json_to_encode, options={} )
    return nil unless json_to_encode
    
    options[:root_name] ||= DEFAULT_ROOT_NAME
    unless options[:parent]
      options[:parent] = REXML::Element.new options[:root_name]
      options[:parent].attributes["xmlns:yaml"] = NAMESPACE
    end
    
    parent = options[:parent]
    
    if json_to_encode.is_a?Hash
      json_to_encode.each_pair do | key, value |
        key.to_s if key.is_a?Symbol
        el = REXML::Element.new key.to_s
        result = self.json2yaxml( value, {:parent => el} )
        parent.add result if result
      end
     
    elsif json_to_encode.is_a?Array
      json_to_encode.each do | x |
        el = REXML::Element.new "_"
        result = self.json2yaxml( x, {:parent => el})
        parent.add result if result
      end
      
    elsif json_to_encode.is_a?String
      parent.text = json_to_encode

    elsif json_to_encode.is_a?(Integer) || json_to_encode.is_a?(Float) || json_to_encode.is_a?(Date) || json_to_encode.is_a?(Symbol)
      parent.text = json_to_encode.to_s
     
    end
     
    parent
  end


  #################################################
  # From YAXML To ANY
  #################################################

  # Conversion YAXML -> YAML
  # 
  # source::
  #   It can be a YAXML file in a String or a file name.
  #
  # Example of use:
  #   test.xml content
  #       <root xmlns:yaml='http://yaml.org/xml'>
  #         <three>
  #           <_>apple</_>
  #           <_>pear</_>
  #         </three>
  #         <two>2.0</two>
  #         <one>1</one>
  #         <four>
  #           <bb>22</bb>
  #           <aa>11</aa>
  #         </four>
  #       </root>
  #
  #   yaml = YAXML.yaxml2yaml "test.xml"
  #   puts yaml
  #   #-> one: 1
  #       two: 2.0 
  #       three:
  #         - apple
  #         - pear
  #       four: 
  #         aa: 11
  #         bb: 22
  def self.yaxml2yaml( source )
    self.yaxml2json( source ).to_yaml
  end

  # Conversion YAXML -> JSON
  # 
  # source::
  #   It can be a YAXML file in a String or a file name.
  #
  # Example of use:
  #   test.xml content
  #       <root xmlns:yaml='http://yaml.org/xml'>
  #         <three>
  #           <_>apple</_>
  #           <_>pear</_>
  #         </three>
  #         <two>2.0</two>
  #         <one>1</one>
  #         <four>
  #           <bb>22</bb>
  #           <aa>11</aa>
  #         </four>
  #       </root>
  #
  #   json = YAXML.yaxml2json "test.xml"
  #   puts json.inspect
  #   #-> {"one" => 1, "two" => 2.0, "three" => [ "apple", "pear"], "four" => {"aa" => 11, "bb" => 22}}
  def self.yaxml2json( source )
    return nil unless source

    xml_node = if source.kind_of?String
                 if File.exist?source
                   yaxml_string = File.open( source, "r" ).read
                 else
                   yaxml_string = source
                 end        
                 REXML::Document.new yaxml_string

               elsif source.kind_of?REXML::Element
                 source.elements[1] if source.elements[1]
                 
               else
                 nil
               end
     
    self.yaxmlnode2json xml_node
  end

  private
  def self.yaxmlnode2json xml_node
    parent ||= if first_element = xml_node.elements[1]
                 if first_element.name == "_"
                   Array.new
                 else
                   Hash.new
                 end
               end

    xml_node.elements.each do |el|
      new_element = (el.has_elements?)? self.yaxmlnode2json( el ) : el.text.strip
      self.add_to_parent( new_element, parent, first_element, el.name )
    end
    
    parent
  end
  
  def self.add_to_parent( element_value, parent, first_element, element_key=nil )
    is_array_list = ( first_element.name == "_" )
    if is_array_list
      parent << element_value
    else
      parent[element_key] = element_value
    end
  end
  
end

# Use examples
#
# doc = YAXML::yaml2yaxml "test.yml"
# puts doc.to_s
# doc.write( $stdout, 2 )
#
# doc = YAXML.yaxml2yaml_from_file "test.xml"
# puts doc.inspect
#
# yaxml = YAXML::Yaxml.new 'test2.yml'
# puts yaxml.to_s
#
# doc = REXML::Document.new yaxml.to_s
# doc.write( $stdout, 2 )
#
# yaxml.write( $stdout, 2 )
# puts yaxml.to_json.inspect
# puts yaxml.to_yaml
