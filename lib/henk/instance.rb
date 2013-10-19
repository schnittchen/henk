require 'henk/commands'
require 'henk/step'

module Henk
  class Instance
    include Commands

    # Block is passed exit status object
    def on_subshell_error(&block)
      @subshell_error_block = block
    end

    # Block is passed script
    def before_subshell(&block)
      @before_subshell_block = block
    end

    # Block is passed sheller result. Called regardless of error status
    def after_subshell(&block)
      @after_subshell_block = block
    end

    def run_commit(*args)
      step = Step.new(self, *args)
      yield step if block_given?
      step.perform!
      step
    end

    def sequence(&block)
      seq = Sequence.new(self)
      if block.arity.zero?
        yield seq
      else
        seq.instance_eval(&block)
      end
    end

    def execute(*args)
      @before_subshell_block.call(Sheller.command(*arguments)) if @before_subshell_block

      result = Sheller.execute(*arguments)

      unless result.exit_status.success?
        block = @subshell_error_block || Proc.new do |status|
          raise "Subshell exited with status #{status}"
        end
        block.call(result.exit_status)
      end

      @after_subshell_block.call(result) if @after_subshell_block

      result
    end

    def execute_for_word(*args)
      sheller_result = execute(*args)
      sheller_result.stdout.chomp if sheller_result.exit_status.success?
    end
  end
end
