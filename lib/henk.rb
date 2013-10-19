require "henk/version"

require "henk/instance"

require 'sheller'

module Henk
  def self.new
    Instance.new
  end
end
