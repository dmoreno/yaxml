module TestFiles
    file_content = {}
    Dir.chdir(File.dirname(__FILE__)) do
        Dir['files/*.{xml,yaml,yml,json,yaxml}'].each do |fname|
          string_content_file = File.open( fname, "r" ).read
          string_content_file.gsub!( /\r\n$/, '' )
          string_content_file.gsub!( /\n$/, '' )
          file_content[fname] = string_content_file
        end
    end
    FILES = file_content
end
