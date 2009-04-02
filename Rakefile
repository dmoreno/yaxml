require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'fileutils'
include FileUtils

NAME = "yaxml"
REV = `svn info`[/Revision: (\d+)/, 1] rescue nil
VERS = ENV['VERSION'] || "0.0.8" + (REV ? ".#{REV}" : "")
PKG = "#{NAME}-#{VERS}"
RDOC_OPTS = ['--quiet', '--title', 'The YAXML Module Reference', '--main', 'README', '--inline-source']
PKG_FILES = %w(CHANGELOG LICENSE README Rakefile) + Dir.glob("{doc,test,lib}/**/*") 

SPEC =
  Gem::Specification.new do |s|
    s.name = NAME
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.has_rdoc = true
    s.rdoc_options += RDOC_OPTS
    s.extra_rdoc_files = ["README", "CHANGELOG", "LICENSE"]
    s.summary = "Library to manage YAXML files"
    s.description = s.summary
    s.author = "Diego Moreno"
    s.email = 'dmoreno@dit.upm.es'
    s.homepage = 'http://yaxml.rubyforge.com/'
    s.files = PKG_FILES
    s.require_paths = ["lib"]
    s.rubyforge_project = "yaxml"
  end

desc "Does a test run"
task :default => [:test]

Rake::GemPackageTask.new(SPEC) do |pkg| 
  pkg.need_tar = true 
end

desc "Run all the tests"
Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/test_*.rb']
    t.verbose = true
end

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.main = "README"
    rdoc.rdoc_files.add ['README', 'CHANGELOG', 'LICENSE', 'lib/*.rb']
end

Rake::GemPackageTask.new(SPEC) do |p|
    p.need_tar = true
    p.gem_spec = SPEC
end

