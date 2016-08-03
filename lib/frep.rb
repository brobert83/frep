module Frep

  require 'release/release'
  require 'release/release_model'
  require 'release/release_process'

  def self.doit file

    release_definition = file ?
        File.expand_path(file) :
        File.expand_path('release.yml', File.dirname(__FILE__))

    Release.new.run_yaml release_definition

  end

end