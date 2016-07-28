class Frep

  def self.doit
    Release.new.run_yaml File.expand_path('release.yml',__FILE__)
  end

end