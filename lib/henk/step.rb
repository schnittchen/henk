module Henk
  class Step
    attr_reader :image

    def initialize(henk, *args)
      @henk = henk
      @arguments = args
    end

    # called with container id (string) and exit code (numeric)
    def after_wait(&block)
      @after_wait_block = block
    end

    # called with container id (string) and exit code (numeric)
    def on_bad_exit(&block)
      @bad_exit_block = block
    end

    def perform!
      container = @henk.execute_for_word(@arguments)
      return unless container

      container_exit = @henk.wait(container)

      @after_wait_block.call(container, container_exit)

      unless container_exit.zero?
        block = @bad_exit_block || Proc.new do
          raise "Container #{container} exited with code #{container_exit}"
        end
        block.call(container, container_exit)
      end

      @image = @henk.commit(container)
    end
  end
end
