require 'release/util/utilities'

class ReleaseProcess

  include Utilities

  def initialize(dry_run, snapshots)
    @summary ||=[]
    @dry_run=dry_run
    @snapshots=snapshots
  end

  def show_summary

    return if @summary.size==0

    help_info "\nSummary"

    @summary.each_with_index do |step, index|
      help_info "\n#{index}. #{step}"
    end

  end

  def step(info, commands)
    echo_with_color "#{info}", 'green'
    puts "\n#{commands.join("\n")}"

    log_commands ||=[]
    commands.each do |command|

      internal_call_match = /^\$\$(.+)$/.match(command)
      if internal_call_match
        internal_method_call = internal_call_match.captures[0]
        log_commands << internal_method_call
        eval("#{internal_method_call}")
      else
        log_commands << command
        system(command) unless @dry_run
      end

    end

    @summary << "#{info}: \n\t#{log_commands.join("\n\t")}"
    self
  end

  def set_release_versions
    pom=read_file 'pom.xml'

    @snapshots.each do |snapshot|

      dependency_tag = snapshot[0]
      snapshot_version = snapshot[1]
      release_version = snapshot[2]

      pom=pom.gsub(
          /<#{dependency_tag}>#{snapshot_version}<\/#{dependency_tag}>/,
          "<#{dependency_tag}>#{release_version}</#{dependency_tag}>"
      )
    end

    write_file 'pom.xml',pom
  end

  def set_snapshot_versions
    pom=read_file 'pom.xml'

    @snapshots.each do |snapshot|

      dependency_tag = snapshot[0]
      release_version = snapshot[2]
      next_snapshot_version = snapshot[3]

      pom=pom.gsub(
          /<#{dependency_tag}>#{release_version}<\/#{dependency_tag}>/,
          "<#{dependency_tag}>#{next_snapshot_version}</#{dependency_tag}>"
      )
    end

    write_file 'pom.xml',pom
  end

end