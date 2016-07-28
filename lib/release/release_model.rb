require 'rexml/document'

$snapshot_dependency=/<(.+version)>(.+\-SNAPSHOT)<\//
$snapshot_version=/(.+)\-SNAPSHOT/
$version=/(.+\.)([0-9]+)/

class ReleaseModel

  include Utilities

  def initialize

    @dry_run = (ask 'Dry run?','n') == 'y'

    @release_version = ask 'What should the release version be?', read_release_version
    verify_pattern_terminate @release_version, $version

    @next_version = ask 'What should the next SNAPSHOT version be?', (next_snapshot @release_version)
    verify_pattern_terminate @next_version, $snapshot_version

    @release_branch = "release/#{@release_version}"
    @snapshots = File.open('pom.xml').read.scan($snapshot_dependency)

    read_snapshot_versions
    prepare_new_iteration_deps

    echo_with_color "\n\n====================Release information========================================================",'green'
    puts "\nDry run: #{@dry_run}"
    if @dry_run
      help_info "---> IMPORTANT: Dry run will still change the snapshot dependencies versions (if any), don't forget to revert those changes\n"
    end

    help_info "\n1. Release version: "; puts release_version
    help_info "\n2. Next snapshot version: ";puts next_version
    help_info "\n3. Snapshot dependencies found:\n"

    unless @snapshots.size==0

      help_info "#{column 'Dependency'} : #{column 'Current version'} -> #{column 'Release version'} -> #{column 'New iteration version'}\n"
      @snapshots.each do |snapshot|
        puts "#{column snapshot[0]} : #{column snapshot[1]} -> #{column snapshot[2]} -> #{column snapshot[3]}"
      end
    end
    echo_with_color "\n=================================================================================================",'green'
  end

  def column(value)
    right_padding value,30;
  end

  attr_reader :release_version, :next_version, :release_branch, :dry_run, :snapshots

  def read_release_version
    artifact_version = REXML::Document.new(File.new('pom.xml')).elements['/project/version'].text
    verify_pattern_terminate artifact_version, $snapshot_version
    $snapshot_version.match(artifact_version).captures[0]
  end

  def read_snapshot_versions
    unless @snapshots
      return
    end

    help_info "\n\nFound dependencies with SNAPSHOT versions:"
    @snapshots.each do |snapshot|
      default_version=$snapshot_version.match(snapshot[1]).captures[0]
      release_version=self.ask "What release version to use for ==> #{snapshot[0]}?", default_version
      snapshot << (release_version == 'y' ? default_version : release_version)
    end
  end

  def prepare_new_iteration_deps
    unless @snapshots
      return
    end

    help_info "\n\nSet SNAPSHOT versions for dependencies for the next iteration"
    @snapshots.each do |snapshot|
      default_version = next_snapshot snapshot[2]
      snap_version=self.ask "For the next iteration, what snapshot version to use for ==> #{snapshot[0]}?", default_version
      snapshot << (snap_version == 'y' ? default_version : snap_version)
    end
  end

end
