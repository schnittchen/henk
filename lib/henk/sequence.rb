require 'henk/step'

module Henk
  class Sequence
    attr_reader :image

    def initialize(henk)
      @henk = henk
    end

    # called with container id (string) and exit code (numeric)
    def after_wait(&block)
      @after_wait_block = block
    end

    # called with container id (string) and exit code (numeric)
    def on_bad_exit(&block)
      @bad_exit_block = block
    end

    def step(*args)
      result = Step.new(@henk, *args)
      result.after_wait(@after_wait_block) if @after_wait_block
      result.on_bad_exit(@bad_exit_block) if @bad_exit_block
      result.perform!
      @image = result.image
      result
    end
  end
end
