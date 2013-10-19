module Henk
  module Commands
    def pull(name)
      execute('docker', 'pull', name)
    end

    def resolve_image_name(name)
      result = execute_for_word('docker', 'images', '-q', name)
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
  end
end
