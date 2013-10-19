require 'sheller'

module Henk
  extend self

  def spawn(*arguments, &block)
    block ||= method(:default_error_handler)

    result = Sheller.execute(*arguments)

    block.call(arguments, result) unless result.exit_status.success?

    result
  end

  def spawn_for_id(*arguments, &block)
    sheller_result = spawn(*arguments, &block)

    sheller_result.stdout.chomp if sheller_result.exit_status.success?
  end

  def default_error_handler(sheller_arguments, sheller_result)
    raise "Subshell invocation #{sheller_arguments.join ' '} failed, exit status #{sheller_result.exit_status}"
  end

  def pull(name, &block)
    spawn('docker', 'pull', name, &block)
  end

  # can we make good use of this in Sequence?
  def wait(container, &block)
    exit_code_string = spawn_for_id('docker', 'wait', container, &block)

    yield exit_code_string if block_given? && exit_code_string != '0'

    exit_code_string
  end

  def commit(container, &block)
    spawn_for_id('docker', 'commit', container, &block)
  end

  class Sequence
    include Henk

    attr_reader :image

    def log_spawn(&block)
      @log_spawn_block = block
    end

    def on_error(&block)
      @error_block = block
    end

    def on_bad_exit(&block)
      @bad_exit_block = block
    end

    def after_wait(&block)
      @after_wait_block = block
    end

    def spawn(*arguments, &block)
      @log_spawn_block.call(Sheller.command(*arguments)) if @log_spawn_block
      super
    end

    def step(*arguments)
      @image = nil

      container = spawn_for_id(*arguments, &@error_block)
      return unless container

      wait_result = spawn('docker', 'wait', container)
      return unless wait_result.exit_status.success?

      exit_code_string = wait_result.stdout.chomp

      @after_wait_block.call(container, exit_code_string) if @after_wait_block

      unless exit_code_string == '0'
        bad_exit_block.call(exit_code_string)
        return
      end

      @image = commit(container, &@error_block)
    end

    def bad_exit_block
      @bad_exit_block ||= Proc.new do |exit_code_string|
        raise "Container exited with code #{exit_code_string}"
      end
    end
  end
end
