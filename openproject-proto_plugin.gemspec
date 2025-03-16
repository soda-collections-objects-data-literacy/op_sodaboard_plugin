# encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)

require 'open_project/proto_plugin/version'
# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openproject-proto_plugin"
  s.version     = OpenProject::ProtoPlugin::VERSION
  s.authors     = "Johannes Schäffer"
  s.email       = "johannes.schaeffer@hu-berlin.de"
  s.homepage    = "https://sammlungen.io"  # TODO check this URL
  s.summary     = 'OpenProject SODa Roadmap Plugin'
  s.description = "A prototypical OpenProject plugin"
  s.license     = "GPLv3"

  s.files = Dir["{app,config,db,lib}/**/*"] + %w(CHANGELOG.md README.md)

  s.add_dependency "rails", '~> 7.0'
end
