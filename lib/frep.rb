
module Frep

  require 'release/release'
  require 'release/release_model'
  require 'release/release_process'

  def self.doit
    Release.new.run_yaml File.expand_path('release.yml',__FILE__)
  end

end