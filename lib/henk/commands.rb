module Henk
  module Commands
    def pull(name)
      execute('docker', 'pull', name)
    end

    def resolve_image_name(name)
      return resolve_untagged_image_name(name) unless name.include?(':')

      # this is a kludge.
      lines = execute_for_lines('docker', 'images')
      lines = lines.map { |line| line.split(/ +/) }

      raise "'docker images' output not as expected" unless
        lines.first.length == 5 &&
        lines.first[0..1] == %w(REPOSITORY TAG)

      line = lines.find { |l| l[0..1].join(':') == name}
      line && line[2]
    end

    def resolve_untagged_image_name(name)
      result = execute_for_word('docker', 'images', '-q', name)
      raise "image name #{name} is ambiguous" if result.include?("\n")
      result unless result.empty?
    end

    def wait(container)
      result = execute_for_word('docker', 'wait', container)
      result &&= Integer(result)
    end

    def commit(container)
      execute_for_word('docker', 'commit', container)
    end

    def logs(container)
      execute('docker', 'logs', container)
    end

    def tag(image, repository, tag = nil, options = {})
      command_options = []
      command_options << '-f' if options[:force]

      execute 'docker', 'tag', *command_options, image, repository, *tag
    end

    def kill(*containers)
      execute('docker', 'kill', *containers)
    end
  end
end
