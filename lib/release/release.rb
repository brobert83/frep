require 'yaml'
require 'release/util/utilities'

class Release

  include Utilities

  def run_yaml(yaml_path)
    @release_model = ReleaseModel.new

    wait_or_do "\nStarting the release process" do
      terminate
    end

    puts

    release = ReleaseProcess.new(@release_model.dry_run, @release_model.snapshots)

    config = YAML::load_file(yaml_path)

    index=1
    config.each do |section_description, commands|
      variables_replaced = commands.map { |command| replace_vars(command) }
      release.step("#{index}. #{replace_vars section_description}",variables_replaced)
      index+=1
    end
  end

  def replace_vars(yaml_content)
    yaml_content % {
        :release_branch => @release_model.release_branch,
        :release_version => @release_model.release_version,
        :next_version => @release_model.next_version
    }
  end

end