require 'colorize'
require 'io/console'

module Utilities

  def echo_with_color(text, color)
    print text.send("#{color}")
  end

  def terminate
    abort "\nProgram terminated"
  end

  def help_info(text)
    echo_with_color text, 'yellow'
  end

  def verify_pattern_terminate(value, regex)
    verify_pattern value, regex do
      terminate
    end
  end

  def verify_pattern(value, regex)
    unless regex.match(value)
      echo_with_color "#{value} must match #{regex}", 'red'
      yield
    end
  end

  def ask(question, suggestion)
    puts
    echo_with_color "#{question} #{suggestion} : ", 'green'
    $stdout.flush

    answer = $stdin.gets.chomp

    return answer unless answer == ''

    echo_with_color suggestion, 'yellow'
    suggestion
  end

  def wait_or_do(message)
    echo_with_color message, 'red'
    unless (ask 'Continue?', 'y') == 'y'
      yield
    end
  end

  def read_file(file_name)
    File.open(file_name).read
  end

  def write_file(file_name, file_content)
    File.open(file_name, 'w') do |file|
      file.write(file_content)
    end
  end

  def next_snapshot(version)
    parts = $version.match(version).captures
    "#{parts[0]}#{Integer(parts[1])+1}-SNAPSHOT"
  end

  def right_padding(string,length)
    (string + ' ' * length)[0,length]
  end

end
